<!DOCTYPE HTML>
<cfsilent>
	<CFSET PAGE_TITLE="Home">
	<cfset application.util.query.request_settings()>
</cfsilent>
<html>
<head>
</head>
<body style="padding:0;margin:0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- If the user has no access to a feature, use this style --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<style>
	.no_access {
		color:gray;
	}
	div.sc_hdr {
		border-radius: 8px 8px 0 0;
		border: 2px solid #4169E1;
		color: white;
		font-weight: 550;
		height: 24px;
		letter-spacing: 0.15px;
		line-height: 24px;
		text-align: left;
		width: 280px;
	}
	img.search {
		position: relative;
		top: 2px;
		padding: 0 5px 0 100px;
	}
    span.new {
        font-size: 0.7rem;
        opacity: 0.75;
    }
</style>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Use this include to maintain backswards compatibility											 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the profile for this user																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<cfset SPA = CreateObject("component","components.user.settingsPanelAccess").init() />
<cfset getSPA = SPA.getSPAccess()>
<cfset IsSPAccessAllowed = SPA.getCheckSPAccessAllowed()>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Give this window a name so that popup based forms can return data to it						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<script language="JavaScript">
	<!--
		this.window.name="mywindowname";
	//-->
</script>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!---<cfif application.deductionLinksAvailable>  --->
<cfif application.appSettingsGet.getDeduction_Module()>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Unlock all locked deductions under this user --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!---
	<cfset useLakebaseForUnlockDDUnderThisUser = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForUnlockDDUnderThisUser>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{
				"locked_by" = "eq.#request.AccessStructure.user_ID#",
				"dd_locked_by_match_central" = "eq.0"
			},
			{
				"is_locked" = "0",
				"locked_by" = ""
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUnlockDDUnderThisUser = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUnlockDDUnderThisUser>
<CFQUERY NAME="UnlockDDUnderThisUser" DATASOURCE="#Application.Datasource#">
		UPDATE	Deductions
		SET 	Is_Locked=0,
				Locked_By=''
		WHERE	Locked_By = '#request.AccessStructure.user_ID#'
			AND DD_Locked_By_Match_Central = 0
	</CFQUERY>
</cfif>
	--->
	<cfset useLakebaseForDeductionsProfilesSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions_profiles_settings")>
<cfif useLakebaseForDeductionsProfilesSettings>
	<cftry>
		<cfset DeductionsProfilesSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions_profiles_settings", {
				"profiles_id" = "eq.#Get_Profile_Settings.Profiles_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeductionsProfilesSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionsProfilesSettings>
<cfquery name="DeductionsProfilesSettings" datasource="#application.datasource#">
		SELECT * FROM Deductions_Profiles_Settings WHERE Profiles_ID = '#Get_Profile_Settings.Profiles_ID#'
	</cfquery>
</cfif>
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber= 1>
<cfinclude template="/helpsystem/help_link2.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Set the color of the gradient used --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET gradientcolor=3>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- USDANOI --->
<cfset usdanoi_on = 0>
<cfset usdanoi_component_id = "0">
<cfif application.util.query.get_setting("usdanoi_enabled") eq "1">
	<cfset useLakebaseForgetusdanoicomponentid = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_component_name")>
<cfif useLakebaseForgetusdanoicomponentid>
	<cftry>
		<cfset getusdanoicomponentid = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_rebates_component_name", {
				"is_usda_noi_comp" = "eq.1",
				"deleted" = "eq.0",
				"select" = "program_rebates_component_name_id"
			}), "program_rebates_component_name_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetusdanoicomponentid = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetusdanoicomponentid>
<cfquery name="getusdanoicomponentid" datasource="#application.datasource#">
		SELECT Program_Rebates_Component_Name_ID
		  FROM Program_Rebates_Component_Name
		 WHERE Is_USDA_NOI_Comp = 1 AND Deleted = 0
	</cfquery>
</cfif>

	<cfif getusdanoicomponentid.recordcount GT 0>
		<cfset usdanoi_on = 1>
		<cfset usdanoi_component_id = getusdanoicomponentid.Program_Rebates_Component_Name_ID>
	</cfif>
</cfif>

<STYLE TYPE="text/css">
	.scorecard
	{
		border: 2px solid #ddd;
	}
	iframe.scorecard {
		border-top: 0px;
		border-radius: 0 0 8px 8px;
		width: 280px;
	}
	.scorecardtitletext
	{
		color: White;
		font-size: 14px;
	/*	font-weight: bold; */ /* SAH Home Page Update */
	}
	.scorecardtitlebackground
	{
		background-color: #4169E1;
	}
	.scorecardtitlebackgrounddisabled
	{
		background-color: gray;
	}
	A, A:LINK, A:VISITED
	{
		color : Blue;
		text-decoration : none;
	}

	A:FOCUS,A:HOVER
	{
		color : Red;
		text-decoration : underline;
	}

</STYLE>

<!---Gets application settings--->
<!--- <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() /> --->
<cfscript>
	appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
	userManager = CreateObject("component", "components.user.UserManager");
	qGetUser            = userManager.getUser(request.AccessStructure.User_ID);
	createProgramAccess = Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 1 AND (appSettings.getUserNumberRestrict() EQ 0 OR userManager.getUserNumberExists(request.AccessStructure.User_ID) EQ 1);

	// <!--- Dev Note: KAL; 8187 --->
	surveyManager          = createObject("component", "components.survey.surveymanager");
	SurveySettings		   = surveyManager.getSurveyOn();
	SurveySettingsURL	   = surveyManager.getSurveyURL();
	SurveyPopupDisplayChek = surveyManager.HomeDisplayChek("#request.AccessStructure.User_ID#");

	// <!--- D64200 :: Create new accrual budget forecast process START --->
	CustomerSettingsLabels = createObject("component", "mvc.Models.SettingsService").getCustomerSettingsLabels();
</cfscript>

<!--- D64200 :: Create new accrual budget forecast process END --->
<cfif SurveyPopupDisplayChek EQ 1>
	<script> NewWindow('/survey/SurveyAlert.cfm','BlacksmithSurveyPopup','400','300','No','No'); </script>
</cfif>


<CFOUTPUT>
<table CLASS="normal-home" border="0" cellpadding="2" cellspacing="0" width="100%" ALIGN="center">
	<tr>
		<td rowspan="5" width="45%" VALIGN="top">

        <cfset request.config = application.util.query.get_settings("Redistribution_Format", 0)>

		<TABLE WIDTH="100%" CELLPADDING="0" CELLSPACING="5" BORDER="0">
			<cfif SurveySettings EQ 1><tr>
				<td>&nbsp;</td>
				<td colspan="2" align="justify">
				<A HREF="##" onclick="NewWindow('/survey/SurveyDisplay.cfm','BlacksmithSurveyDisplay','700','600','No', 'No');">
					<div align="center"><img src="/images/survey_feedback.gif" align="middle" alt=""></div>
				</A>
				</td>
			</tr></cfif>
			<TR>
				<TD rowspan="2" ALIGN="center" VALIGN="top"><BR><IMG SRC="/images/round_programs.gif" WIDTH="40" HEIGHT="40" ALT="" BORDER="0"></TD>
				<TD COLSPAN="2" WIDTH="100%" STYLE="border-bottom: 2px solid ##aaaa00"><BR><B>Programs</B></TD>


			</TR>
			<TR>
				<TD <!--- WIDTH="50%" --->>
					<CFIF createProgramAccess>
						<A HREF="##" TITLE="create a new program" OnClick="CallJS()">Create Program</A><BR>
					</CFIF>

                    <CFIF ABS(Get_Profile_Settings.Cont_Prog_View_Create_Program) EQ 1>
                            <!--- Dev Note: drachala; D29074 : Add option to program search to allow user to search on GL Account  START
                            Added/Changed: Added new IF conditions to displayin links--->
							<cfif appSettings.getFlexProgramSearch() EQ 1>
								<A HREF="/Scorecard/program_Search.cfm?type=html" TITLE="search for a program">Search Program</A><BR>
							<cfelseif appSettings.getFlexProgramSearch() EQ 2>
								<A HREF="/flex/search/ProgramSearchFx.cfm" TITLE="search for a program">Search Program</A><BR>
							<cfelseif appSettings.getFlexProgramSearch() EQ 3>
								<A HREF="/Scorecard/program_Search.cfm?type=html&searchType=1&fromHomePage=1" TITLE="search for a program">Advanced Program Search </A> <BR>
								<A HREF="/flex/search/ProgramSearchFx.cfm" TITLE="search for a program">Program Search</A><BR>
							<cfelseif appSettings.getFlexProgramSearch() EQ 4>
								<A HREF="##" onClick="showProgramSearch()" TITLE="search for a program">Program Search</A><BR>
							<cfelseif appSettings.getFlexProgramSearch() EQ 5>
								<A HREF="/Scorecard/program_Search.cfm?type=html&searchType=1&fromHomePage=1" TITLE="search for a program">Advanced Program Search </A> <BR>
								<A HREF="##" onClick="showProgramSearch()" TITLE="search for a program">Program Search</A><BR>
							</cfif>
							<!--- End Dev Note: drachala; D29074: Add option to program search to allow user to search on GL Account  --->
					</CFIF>



					<!--- (Start) Only if the Export Program App Setting is turned on --->
					<cfif appSettings.getShowExportPrograms()>
						<CFIF ABS(Get_Profile_Settings.Create_Export_Agreements) EQ 1 OR ABS(Get_Profile_Settings.Create_Approve_Export_Agreements) EQ 1>
							<A HREF="/common_files/sales_agreement_select_new_program_type.cfm" TITLE="create a new program">Create Export Program</A><BR>
						</CFIF>

						<CFIF ABS(Get_Profile_Settings.Create_Export_Agreements) EQ 1 OR ABS(Get_Profile_Settings.Approve_Export_Agreements) EQ 1 OR ABS(Get_Profile_Settings.Create_Approve_Export_Agreements) EQ 1>
							<A HREF="/Scorecard/sales_agreement_Search.cfm" TITLE="search for an export program">Search Export Program</A><BR>
						</CFIF>

						<CFIF ABS(Get_Profile_Settings.Create_New_Export_Customer) EQ 1>
							<A HREF="/common_files/contracts/sales_agreement_customer_request.cfm" TITLE="Create a new customer for export business">Create new Export Customer</A><BR>
						</CFIF>
					</cfif>
					<!--- (End) Only if the Export Program App Setting is turned on --->

					<!------ futures pricing ----->
					<cfif appSettings.getFuturesPricingAvailable()>
						<CFIF createProgramAccess>
							<A HREF="/Futures_Pricing/index.cfm" TITLE="futures pricing">Futures Pricing</A><BR>
						</CFIF>
					 </cfif>

					<CFIF Get_Profile_Settings.Commodity_Settings EQ 1>
						<A HREF="/profits/index.cfm">Commodity Costs</A><BR>
					</CFIF>

					<cfif appsettings.getapprovalmatrixoff() EQ 0>
						<CFIF Get_Profile_Settings.Cont_Prog_Approval_Rights EQ 1>
							<A HREF="/Common_Files/Margin_Matrix/index.cfm">Approval Matrix</A><BR>
						</CFIF>
					</cfif>
				</TD>
				<TD VALIGN="Top">
					<cfif appsettings.gettradeplanneroff() EQ 0>
						<cfif ListFindNoCase("Pactiv,Lambweston",application.returned_customer_setting.customer_keyword) eq 0>
							<A HREF="/ReportWriter/trade_plan/index.cfm"  TITLE="#application.returned_customer_setting.Trade_Label# #Application.PlannerLabel#">#application.returned_customer_setting.Trade_Label# #Application.PlannerLabel#</A><BR>
						</cfif>
					</cfif>
					<CFIF Get_Profile_Settings.Reassign_Program_Access EQ 1>
						<A HREF="/Common_Files/Contracts/Reassign_Programs.cfm" TITLE="reassign programs to a different user position">Reassign</A><BR>
					</CFIF>

					<CFIF usdanoi_on EQ 1>
						<a href="/settings/usdanoi/noi_usage_agreement.cfm">USDA NOI Search</a><BR>
					</CFIF>

					<!--- D64200 :: Create new accrual budget forecast process START --->
					<CFIF appSettings.get_Setting('Annual_Budget_Forecast') eq '1' AND Get_Profile_Settings.Budget_Forecast EQ 1>
						<A HREF="##" onclick="popupCenterByPercentages('/settings/Advanced_Budget/budget_forecast.cfm', 'budget_forecast', 74, 64)">Create #CustomerSettingsLabels.budget_forecast_label#</A><BR>
					</CFIF>

					<cfif createProgramAccess and Get_Profile_Settings.Upload_Programs EQ 1>
						<a href="/programs/upload/index.cfm" title="upload programs">Upload Programs</a><br>
					</cfif>
					<!--- D64200 :: Create new accrual budget forecast process END --->
				</TD>
			</TR>

			<!--- START: 57305: Retail Planner/09-Mar-2016/Anand Rao --->
			<cfif appSettings.get_Setting('Retail_Planner') EQ '1'>
				<tr>
					<TD rowspan="2" ALIGN="center" VALIGN="top"><BR><IMG SRC="/images/round_planners.gif" WIDTH="40" HEIGHT="40" ALT="" BORDER="0"></TD>
					<TD COLSPAN="2" WIDTH="100%" STYLE="border-bottom: 2px solid ##cccc33;"><BR><B>#Application.PlannerLabel_Plural#</B></TD>
				</tr>
				<tr>
					<td valign="top">
						<cfif Get_Profile_Settings.Planner_Create EQ 2>
							<A HREF="/planners/create/index.cfm">Create #Application.PlannerLabel#</A><BR>
						</cfif>
						<cfif ListFindNoCase("1,2", Get_Profile_Settings.Planner_Create)>
							<A HREF="/Planners/Search/Planner_Search.cfm">Search #Application.PlannerLabel#</A><BR>
						</cfif>
						<cfif Get_Profile_Settings.Planner_Reassign eq 1>
							<a href="/planners/reassign/index.cfm">Reassign #Application.PlannerLabel_Plural#</a><br>
						</cfif>
						<cfif Get_Profile_Settings.Planner_Create EQ 2>
							<a href="/Planners/Import/planner_import_programs.cfm?action=import_planners">Import #Application.PlannerLabel_Plural#</a><br>
						</cfif>
					</td>
					<td valign="top">
						<!--- consumer events --->
						<cfif Get_Profile_Settings.Marketing_Events_Create EQ 1>
							<a href="/planners/consumer_events/index.cfm">Consumer Events</a><br>
						</cfif>
						<!--- consumer events calendar --->
						<cfif Get_Profile_Settings.Planner_Product_Calendar EQ 1>
							<a href="/planners/consumer_events/events/calendar.cfm">Consumer Calendar</a><br>
						</cfif>
						<cfif Get_Profile_Settings.NUC_Targets_Create EQ 2>
							<A HREF="/settings/planners/nuc_targets/index.cfm?PageTitle=NUC Targets">NUC Targets</A><BR>
						</cfif>
					</td>
				</tr>
			</cfif>
			<!---- END: 57305 ---->

			<cfset variables.billbackModule = application.appSettingsGet.getBillback_Module()>
			<!---<CFIF application.returned_customer_setting.show_billback EQ 1  --->
			<CFIF variables.billbackModule eq 1>
			<TR>
				<TD rowspan="2" ALIGN="center" VALIGN="top"><BR><IMG SRC="/images/round_billbacks.gif" WIDTH="40" HEIGHT="40" ALT="" BORDER="0"></TD>
				<TD COLSPAN="2" WIDTH="100%" STYLE="border-bottom: 2px solid ##4169E1;"><BR><B>Billbacks</B></TD>
			</TR>
			</CFIF>

			<TR>
				<TD VALIGN="top">
					<cfif (appSettings.get_Setting('OCR_Upload_ON') EQ '1')>
						<CFIF (
								variables.billbackModule EQ 1 AND Get_Profile_Settings.BB_Create EQ 1 AND appSettings.getShowManualBillback() OR
								appSettings.get_Setting('OCR_Upload_ON') EQ '1' OR
								(appSettings.getBB_Upload_Updated() EQ 1 AND getSpa.Upload_Billback_index)
								)>
								Create &amp; Manage Billbacks:<br>

							<cfif variables.billbackModule EQ 1 AND Get_Profile_Settings.BB_Create EQ 1 AND appSettings.getShowManualBillback()>
								<!---
										31505:	App setting for Flex BB Module/Anand Rao/24-Apr-2012
									  	If it is Flex then take to flex pages to create for all other take to older method
								--->
								<cfif appsettings.getBillbackModuleType() EQ 2>
									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- <A HREF="/billbacks/2020/search_billbacks.cfm">Manually</A><BR>
								<cfelse>
									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- <A HREF="/billbacks/capture/index.cfm">Manually</A><BR>
								</cfif>
							</CFIF>
							<cfif (appSettings.getBB_Upload_Updated() EQ 1 AND getSpa.Upload_Billback_index)>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- <a href="/billbacks/OCR_Upload/payablesRedirect.cfm?redirectTo=UPLOAD">From Forge Excel Format</a> <br>
							</cfif>
							<cfif appSettings.get_Setting('OCR_Upload_ON') eq '1'>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- <a href="/billbacks/OCR_Upload/index.cfm">From Invoices</a><br />
							</cfif> <!--- <cfif appSettings.get_Setting('OCR_Upload_ON') eq '1'> --->
						</cfif> <!--- Check all the combination, for displayig the "Create billback" header --->
					<cfelse>
						<CFIF variables.billbackModule EQ 1 AND Get_Profile_Settings.BB_Create EQ 1 AND appSettings.getShowManualBillback()>
							<!---
									31505:	App setting for Flex BB Module/Anand Rao/24-Apr-2012
										If it is Flex then take to flex pages to create for all other take to older method
							--->
							<cfif appsettings.getBillbackModuleType() EQ 2>
								<A HREF="/billbacks/2020/search_billbacks.cfm">Create Billback</A><BR>
							<cfelse>
								<A HREF="/billbacks/capture/index.cfm">Create Billback</A><BR>
							</cfif>
						</CFIF>
					</cfif>
					<CFIF appSettings.getShowAutoBillback()>
						<CFIF Get_Profile_Settings.BB_Create EQ 1>
							<cfif appSettings.getAutoBillBackType()>
								<A HREF="/billbacks/capture/INDEX.CFM?AUTOBB=2">Create Auto Billback</A><BR>
							<cfelse>
								<A HREF="/billbacks/capture/INDEX.CFM?AUTOBB=1">Create Auto Billback</A><BR>
							</cfif>
						</CFIF>
					</CFIF>
					<CFIF variables.billbackModule EQ 1 and ListFindNoCase("1,2", Get_Profile_Settings.BB_Create)>

						<cfif appsettings.getBillbackModuleType() EQ 1>
							<A HREF="/Billbacks/Scorecard/billback_Search.cfm?searchType=advanced">Advanced Search Billbacks</A><BR>
							<A HREF="/Billbacks/Scorecard/billback_Search.cfm">Search Billbacks</A><BR>
						<cfelse>
							<A HREF="/billbacks/2020/search_billbacks.cfm">Search Billbacks</A><BR>
						</cfif>
					</CFIF>
					<CFIF application.returned_customer_setting.Show_Pay_Multi_BB_Link EQ 1>
						<!---<CFIF application.returned_customer_setting.show_billback EQ 1  --->
						<CFIF variables.billbackModule>
							<A HREF="/Billbacks/Multi_BB_Payment/Distributor_And_BB_Form.cfm">Pay Multiple Billbacks</A><BR>
						</CFIF>
					</CFIF>
					<CFIF variables.billbackModule EQ 1 AND appSettings.getView_Trade_Checkbook() IS 1 AND Get_Profile_Settings.Show_Trade_Checkbook EQ 1>
						<A HREF="/billbacks/ledger/index.cfm">#application.returned_customer_setting.Trade_Label# checkbook</A><BR>
					</CFIF>
					<CFIF Get_Profile_Settings.BB_Reassign EQ 1>
						<A HREF="/Billbacks/Reassign/BB_Reassign.cfm">Reassign Billbacks</A><BR>
					</CFIF>
					<cfif Get_Profile_Settings.Settlements eq 1>
						<a href="/billbacks/OnePageBillback/index.cfm">Settlements</a><br>
					</cfif>
				</TD>
				<TD VALIGN="top">
					<CFIF variables.billbackModule EQ 1 AND appSettings.getView_Auto_Checkbook() IS 1>
						<A HREF="/billbacks/ledger/auto_checkbook/index.cfm">Auto Checkbook</A><BR>
					</CFIF>
					<CFIF variables.billbackModule EQ 1 AND application.returned_customer_setting.customer_keyword IS "conagra" >
						<CFIF Get_Profile_Settings.Reimbursement_Update EQ 1>
							<A HREF="/billbacks/reimbursements/index.cfm">Reimbursements</A><BR>
						</CFIF>
					</CFIF>

					<cfif application.appSettingsGet.getDeduction_Module()>
						<!------ Deduction code ----->
						<CFIF DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 0>
							<A HREF="/deductions/index.cfm">Deductions</A><BR>
						</cfif>
						<cfif appSettings.getDD_Show_reassign()>
							<CFIF (DeductionsProfilesSettings.DD_Reassign_Access EQ 1 AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1)>
								<A HREF="/deductions/Reassign/Bulk_DD_Reassign.cfm">Reassign Deductions</A><BR>
							</CFIF>
						</cfif>
					</cfif>
					<CFIF Get_Profile_Settings.DD_Match_Central eq 1>
						<A HREF="/MatchCentral/index_main.cfm?showSearch=true">Match Central</a><br />
					</CFIF>
					<cfif application.appSettingsGet.get_Setting('BB_Doc_Server_Folder') NEQ ''>
						<CFIF Get_Profile_Settings.Browse_BBDoc_Server_Files EQ 1>
							<A HREF="/common_files/Documents/BrowseBBDocsGet.cfm" onClick="NewWindow(this.href,'BrowseBBDocWin','810','600','Yes', 'No');return false;" >Browse BB Doc Server</A><BR>
						</CFIF>
					</CFIF>
					<CFIF variables.billbackModule EQ 1 AND Get_Profile_Settings.Vendor_Hold_Research eq 1 AND appSettings.get_Setting('Vendor_Batching') eq '1'>
						<cfset billbackLabels = createObject("component", "mvc.Models.SettingsService").getBBLabels() />
						<a href="##" onclick="popupCenterByPercentages('/common_files/processing.cfm?actualPage=/billbacks/vendor_hold.cfm', 'vendor_hold_research', 94, 84)">#billBackLabels["Vendor"]# Batching</a><br />
					</CFIF>
					<!---D57147 :: New Feature to Search for BB's by Customer Invoice --->
					<cfif variables.billbackModule eq 1 and application.util.query.get_setting("Deduction_Module") eq "1" AND  Get_Profile_Settings.Search_Customer_Invoice eq 1>
						<a href="/billbacks/CustomerInvoice/Search_Customer_Invoice.cfm">Search Customer Invoice</a><br>
					</cfif>
				</TD>
			</TR>

			<TR>
				<TD rowspan="2" ALIGN="center" VALIGN="top"><BR><IMG SRC="/images/round_projects.gif" WIDTH="40" HEIGHT="40" ALT="" BORDER="0"></TD>
				<TD COLSPAN="2" WIDTH="100%" STYLE="border-bottom: 2px solid ##BF1D38;"><BR><B>Deployment</B></TD>
			</TR>
			<TR>
				<TD VALIGN="TOP">
				<CFIF Get_Profile_Settings.View_Invoices EQ 1>
					<a href="/search_screens/invoice/search_invoices.cfm" TITLE="search invoices">Invoices</a><BR>
				</CFIF>

				<!---D26123 - Show volume forecast if profile permission is enabled--->
				<cfif Get_Profile_Settings.Volume_Forecast gt 0>
						<a href="/common_files/volume/listVF.cfm" title="Volume Forecast">Volume Forecast</a><br>
				</cfif>
				<cfif appSettings.getProfitabilityModel()>
					<a href="/profits/operator/index.cfm" title="">Operator Profit</a><br />
				</cfif>
				<cfif appSettings.getProgramClaimRatesReportAvailable() AND ABS(Get_Profile_Settings.Cont_Prog_View_Create_Program) EQ 1>
					<a href="/ReportWriter/program_claim_rates_report.cfm" title="">Claim Rates</a> <br/>
				</cfif>
				<cfif Get_Profile_Settings.What_If_From_Scratch eq 1>
					<a href="/common_files/whatif/list_what_if.cfm">What If P&L</a><BR>
				</cfif>
				<!--- 76021 :: Ember:  Open Document from FORGE Application START --->
				<cfif LEN(TRIM(appSettings.get_Setting('Ember_OpenDocument_URL'))) GT '0' AND Get_Profile_Settings.Ember_Access gt 0 AND qGetUser.Ember_Info NEQ "">
					<!--- <a href="/Ember/index.cfm" TITLE="Ember" onClick="NewWindow(this.href,'Ember','1700','980','Yes', 'Yes');return false;" >Ember</a><BR> --->
					<a href="/Ember/index.cfm?sDestination=Ember" TITLE="Ember" onClick="window.open(this.href, 'Ember', 'toolbar=yes, location=yes, directories=no, status=no, menubar=no, copyhistory=no, scrollbars=yes, resizable=yes, width=1700, height=880, top=25, left=100');return false;" >Insights</a><BR>
				</cfif>
				<!--- 76021 :: Ember:  Open Document from FORGE Application END--->
				<!--- 83599 : FORGE Analytics:  SSO From FORGE Application --->
				<cfif LEN(TRIM(appSettings.get_Setting('Analytics_OpenDocument_URL'))) GT '0' AND Get_Profile_Settings.Analytics_SSO gt 0 AND qGetUser.Analytics_SSO_User_Name NEQ "">
					<!--- <a href="/Ember/index.cfm" TITLE="Ember" onClick="NewWindow(this.href,'Ember','1700','980','Yes', 'Yes');return false;" >Ember</a><BR> --->
					<a href="/Ember/index.cfm?sDestination=Analytics" TITLE="Analytics" onClick="window.open(this.href, 'Analytics', 'toolbar=yes, location=yes, directories=no, status=no, menubar=no, copyhistory=no, scrollbars=yes, resizable=yes, width=1700, height=880, top=25, left=100');return false;" >Analytics</a><BR>
				</cfif>
				</TD>

				<TD VALIGN="Top">
                    <CFIF Get_Profile_Settings.Redistribution EQ 1>
                        <cfif request.config.redistribution_format contains "CF">
                            <a onclick="opentab('redistribution')">
                                Redistribution <cfif request.config.redistribution_format contains "flex"><span class="new">(new)</span></cfif>
                            </a><br>
                        <cfelse>
                            <A HREF="##" onclick="NewWindow('/Flex/RediFx.cfm','redi','1200','768','Yes', 'Yes')">Redistribution</A><BR>
                        </cfif>
					</CFIF>


					<!--- START: 103971	Double Dip Report / Anand Rao / 17-Feb-2021 --->
					<cfif (request.settings.Double_Dip_Report eq '1' AND Get_Profile_Settings.DoubleDipReport EQ 1)>
						<a href="/deployment/DblDipReport/index.cfm" TITLE="Double Dip Report" onClick="NewWindow(this.href, 'DoubleDip','1100','600','Yes', 'Yes');return false;" >Double Dip Report</a><BR>
					</cfif>
					<!--- END: 103971	Double Dip Report / Anand Rao / 17-Feb-2021 --->
					&nbsp;
				</TD>
			</TR>
			<TR>
				<TD rowspan="2" ALIGN="center" VALIGN="top"><BR><IMG SRC="/images/round_settings.gif" WIDTH="40" HEIGHT="40" ALT="" BORDER="0"></TD>
				<TD COLSPAN="2" WIDTH="100%" STYLE="border-bottom: 2px solid Green;"><BR><B>Tools</B></TD>
			</TR>
			<TR>
				<TD VALIGN="top">
					<CFIF IsSPAccessAllowed EQ 1>
						<a href="/settings/index2.cfm">Settings</a><BR/>
					</CFIF>
					<CFIF application.personalization EQ 1>
						<A HREF="/settings/personalization/index.cfm">Personalization</a><BR/>
					</CFIF>
					<cfif Get_Profile_Settings.Reports_Access_Level>
						<A HREF="/ReportWriter/index_main.cfm">Reports Central</A><br />
					</cfif>
					<CFIF Get_Profile_Settings.Clause_Library_Access EQ 1>

						<A HREF="/Clause_Library/index.cfm" TITLE="Clause Library">Clause Library</A><BR/>
					</CFIF>


					<!--- Dev Note: KAL; 6/15/2010; D21554: LDAP Authentication - Dont show password option when LDAP is on --->
					<cfif  appSettings.getSingleSignOnOverrideUserId() OR (NOT (appSettings.getLDAP_SSO_Enabled() or request.AccessStructure.SSO_User)) >
						<A HREF="##" onClick="NewWindow('/settings/password_form.cfm?PageTitle=Personal%20Settings:%20change%20password&FromHome=1','name','825','375','Yes', 'Yes')">Change Password</A><BR/>
					</cfif>
					<cfif appSettings.getApprovalViaEmail() or appSettings.get_Setting('BB_Approval_Via_Email') >
						<A HREF="##" onClick="NewWindow('/settings/pin_form.cfm','name','800','375','Yes', 'Yes')">Change PIN</A><BR/>
					</cfif>
					<CFIF application.returned_customer_setting.show_news EQ 1>
						<A HREF="/News_Ticker/Headlines/index.cfm">News Headlines</A><BR/>
					</CFIF>
					<cfif appSettings.getCrucibleOn() AND qGetUser.Crucible_File_Download EQ 1>
						<A HREF="/Crucible/index.cfm">GAUGE<SUP style="font-size:10px">SM</SUP></A><BR/>
					</cfif>

				 </TD>
				 <TD VALIGN="top">
						<!--- DEV NOTE: DAA; D14743 <A HREF="/help_files/Whatsnew/index.cfm">What's new...</A><BR> --->
						<!--- DEV NOTE: DAA; D14743 ---><A HREF="##" onclick="NewWindow('/common_files/about.cfm','about','640','480','Yes', 'Yes')">About</A><BR/>
					<cfif appSettings.getOnePageClaimForm()>
						<A HREF="/billbacks/ClaimForm/bin/ClaimForm.html">One Page Claim Form</A><BR/>
					</cfif>

					<!--- ----------------------------------------------------------------------------------------- --->
					<!--- message center entry																	 	--->
					<!--- ----------------------------------------------------------------------------------------- --->
					<cfif Get_Profile_Settings.Message_Center_Viewing EQ 1>
					<A HREF="/messagecenter/index.cfm?id=94451-84537-17189-37328">Message Center</A><br/>
					</cfif>
					<!--- ----------------------------------------------------------------------------------------- --->
					<!--- ----------------------------------------------------------------------------------------- --->
					<!--- ----------------------------------------------------------------------------------------- --->

					<cfif appSettings.getsinglesign_on() eq 2>
						<a href="javascript:addbookmark()">Bookmark</a><br>
					</cfif>
					<cfif getSPA.Master_Data EQ 1>
						<a href="/settings/master_data/distributor_master_data.cfm">Master Data Search</a><br>
					</cfif>
				</TD>
			</TR>
		</TABLE>


	</td>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Set the height of the Iframes --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- SAH Remove Projects Scorecard and simplify the Height/Width setting --->
	<CFSET iframeHeight=375>
	<CFSET iframeContainerHeight=iframeheight+6>
	<CFSET iframeContainerWidth=284>
	<CFSET iframeWidth=280>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<TD VALIGN="Top" ALIGN="Center">
		<!-------------------------->
		<!--- Programs scorecard --->
		<!-------------------------->
		<cfscript>
			div_class = ( abs(Get_Profile_Settings.Cont_Prog_View_Create_Program) eq 1
							? "scorecardtitlebackground"
							: "scorecardtitlebackgrounddisabled" );
			search_cfm = ( abs(Get_Profile_Settings.Cont_Prog_View_Create_Program) eq 1
								? ( appSettings.getFlexProgramSearch() EQ 2
										? "/flex/search/ProgramSearchFx.cfm"
										: "/programs/program_search.cfm" )
								: "" );
		</cfscript>
		<div class="sc_hdr #div_class#"> &nbsp;
			Program Scorecard
			<cfif search_cfm neq "">
				<a href="#search_cfm#">
					<img src="/images/icon_search_small.gif" title="Search for programs"
							width="19" height="19" border="0" align="right" class="search">
				</a>
			</cfif>
		</div>
		<iframe src="/scorecard/index.cfm?a=#createuuid()#" width="280" height="375" frameborder="0" class="scorecard"></iframe>
	</td>

	<!----------------------------------->
	<!--- right half of the home page --->
	<!----------------------------------->
	<td valign="top" align="center">
		<!--------------------------->
		<!--- Billbacks scorecard --->
		<!--------------------------->
		<cfif Get_Profile_Settings.BB_Create>
		<cfscript>
			div_class = ( variables.billbackModule EQ 1 and ListFindNoCase("1,2", Get_Profile_Settings.BB_Create)
							? "scorecardtitlebackground"
							: "scorecardtitlebackgrounddisabled" );

			if ( variables.billbackModule eq 1 AND ListFindNoCase("1,2", Get_Profile_Settings.BB_Create) ) {
				search_cfm = appsettings.getBillbackModuleType() EQ 1
								? "/Billbacks/Scorecard/billback_Search.cfm"
								: "/billbacks/2020/search_billbacks.cfm";
				iframe_src = "/billbacks/scorecard/scorecard_home.cfm?a=#createuuid()#";
			}
			else {
				search_cfm = "";
				iframe_src = "blank.html";
			}
		</cfscript>

		<div class="sc_hdr #div_class#"> &nbsp;
			Billbacks Scorecard
			<cfif search_cfm neq "">
				<a href="#search_cfm#">
					<img src="/images/icon_search_small.gif" title="Search for billbacks"
							width="19" height="19" border="0" align="right" class="search">
				</a>
			</cfif>
		</div>

		<cfset bb_height = (appSettings.get_Setting('Retail_Planner') eq '1' ? 234 : 375)>
		<iframe src="#iframe_src#" width="280" height="#bb_height#" frameborder="0" class="scorecard" style="margin-bottom: 5px;"></iframe>
		</cfif>

		<!--------------------------->
		<!--- Planner scorecard --->
		<!--------------------------->
		<cfif appSettings.get_Setting('Retail_Planner') eq '1'>
			<cfset search_cfm = "/Planners/Search/Planner_Search.cfm">
			<div class="sc_hdr #div_class#"> &nbsp;
				#Application.PlannerLabel# Scorecard
				<cfif search_cfm neq "">
					<a href="#search_cfm#">
						<img src="/images/icon_search_small.gif" title="Search for #Application.PlannerLabel_Plural#"
								width="19" height="19" border="0" align="right" class="search">
					</a>
				</cfif>
			</div>

			<iframe src="/planners/scorecard/home.cfm" width="280" height="268" frameborder="0" class="scorecard"></iframe>
		</cfif>
	</td>
	</tr>

</table>
</CFOUTPUT>

<cfscript>
	variables.width = 1345;
	variables.height = 710;
	if(application.appSettingsGet.get_Setting('Custom_RFP_Process',0) == 1){
		variables.width = 1875;
		variables.height = 950;
	}
</cfscript>

<SCRIPT language="JavaScript">
	function CellOn(CellName)
	{
		eval("CellName.bgColor = '#4169E1'")
	}

	function CellOff(CellName)
	{
		eval("CellName.bgColor = '#FFFFFF'")
	}

	function showrevisiondetails(contract_number,status)
	{
		NewWindow('/reportwriter/performance_reports/revisionreport.cfm','ProgramRevisionDetails','1200','550','Yes', 'Yes')
	}

	function showoperators()
	{
		NewWindow('/settings/operator_management/select_operators.cfm?searchoperator=1&SelectSingleSearchResultOnly=1','SearchOperators','850','550','Yes', 'Yes')
	}

	function addbookmark()
	{
		var url = location.href;
		var title = document.title;
		if(typeof window.sidebar != 'undefined'){
			window.sidebar.addPanel(title, url, "");
			} else if(document.all){
				window.external.AddFavorite(url, title);
			} else if(window.opera && window.print){
				alert('Press ctrl+D to bookmark (Command+D for macs) after you click Ok');
			} else if(window.chrome){
				alert('Press ctrl+D to bookmark (Command+D for macs) after you click Ok');
			}
	}

	<!--- Dev Note: Milan (22900). We open "Create program" page in a new window when Program Flex is On. --->
	function CallJS()
	{	<cfoutput>
		<cfif appSettings.getFlexProgramSearch()>
			window.open('/common_files/select_new_program_type.cfm','winSummary','height=#variables.height#,width=#variables.width#,toolbar=no,scrollbars=yes,left=0,top=0,screenX=0,screenY=0,resizable=yes');
		<cfelse>
		window.location = '/common_files/select_new_program_type.cfm','winSummary','height=#variables.height#,width=#variables.width#,toolbar=no,scrollbars=yes,left=0,top=0,screenX=0,screenY=0,resizable=yes';
		</cfif>
		</cfoutput>
	}
</SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset request.focusHiLightOff = true>
<cf_include files="/common_files/jQuery.cfm, /styles/css-loader.css, /common_files/dhx_message.cfm">

<script>
	$("a").click(function() {
		var onclick = $(this).prop("onclick");
		if ( onclick ) {
		}
		else {
			pageTitle( $(this).text() );
		}
	});
	pageTitle( "Home" );

    const home_page = { tabs: {} };
    // global constants in browser localStorage
    const REDISTRIBUTION_IS_OPENED = "redistribution_is_opened";   // exists only when redistribution tab is opened

    // 85971
    function opentab( name ) {
        // tab is already opened
        if (home_page.tabs[ name ] && !home_page.tabs[ name ].closed) {
            home_page.tabs[ name ].focus();
        }
        else {
            // tab not yet opened
            switch (name.toLowerCase().trim()) {
                case 'redistribution':
                    if (localStorage.getItem(REDISTRIBUTION_IS_OPENED)) {
                        modal_alert("Redistribution page was opened previously.<br>Please find and click on its tab to activate.")
                    }
                    else {
                        home_page.tabs[ name ] = window.open("/deployment/redistribution/index.cfm", "_blank");
                    }
                    break;
                default:
                    break;
            }
        }
    }

	function showProgramSearch(){
		show_loader( 'LOADING... PLEASE WAIT...');
		window.location.href='/programs/program_search.cfm';
	}
</script>
</BODY>
</HTML>
