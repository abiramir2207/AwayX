<CFSET PAGE_TITLE="Home">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Home</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
		<!--- <meta name="google-translate-customization" content="1d06f2ab974035a-e5ee11c62c2d43e4-g2ee81eac6be86099-12"></meta>	--->
	<script src="/script/javascript/popup.js?32"></script>
</HEAD>

<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" TOPMARGIN="0" MARGINHEIGHT="0" LEFTMARGIN="5" MARGINWIDTH="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Use this include to maintain backswards compatibility											 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the profile for this user																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
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
<!--- If the user has no access to a feature, use this style --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<STYLE>
	.no_access
	{
		color:gray;
	}
</STYLE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!---<cfif application.deductionLinksAvailable>  --->
<cfif application.appSettingsGet.getDeduction_Module()>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Unlock all locked deductions under this user --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

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
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Set the color of the gradient used --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET gradientcolor=3>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- USDANOI --->
<cfset usdanoi_on = 0>
<cfset usdanoi_component_id = "0">
<cfquery name="checkForSettingColumnExistance"  datasource="#application.datasource#">
	SELECT *
	FROM   INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = '_Application_Settings'
	AND
	COLUMN_NAME = 'usdanoi_enabled'
</cfquery>
<CFIF checkForSettingColumnExistance.recordcount GT 0>
	<cfset useLakebaseForisUSDANOI_enabled = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForisUSDANOI_enabled>
	<cftry>
		<cfset isUSDANOI_enabled = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "usdanoi_enabled"
			}), "usdanoi_enabled"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForisUSDANOI_enabled = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForisUSDANOI_enabled>
<cfquery name="isUSDANOI_enabled" datasource="#application.datasource#">
		SELECT usdanoi_enabled
		FROM _Application_Settings
	</cfquery>
</cfif>

	<cfif isUSDANOI_enabled.recordcount GT 0>
		<cfif isUSDANOI_enabled.usdanoi_enabled EQ 1>
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
	</cfif>
</CFIF>

<STYLE TYPE="text/css">
	.scorecard
	{
		border-left: Solid 1px Silver;
		border-right: Solid 1px #444444;
		border-top: Solid 1px Silver;
		border-bottom: Solid 1px #444444;
	}
	.scorecardtitletext
	{
		color: White;
		font-size: 14px;
		font-weight: bold;
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
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfset ShowProjectsScoreCard = appsettings.getShowProjectsScoreCard()>
<cfset userManager = CreateObject("component", "components.user.UserManager") />
<cfset qGetUser = userManager.getUser(request.AccessStructure.User_ID) />
<cfset createProgramAccess = Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 1 AND (appSettings.getUserNumberRestrict() EQ 0 OR userManager.getUserNumberExists(request.AccessStructure.User_ID) EQ 1) />

<!--- Dev Note: KAL; 8187 --->
<cfset SurveySettings		=	CreateObject("component", "components.survey.surveymanager").getSurveyOn() />
<cfset SurveySettingsURL	=	CreateObject("component", "components.survey.surveymanager").getSurveyURL() />
<cfset SurveyPopupDisplayChek =  CreateObject("component", "components.survey.surveymanager").HomeDisplayChek("#request.AccessStructure.User_ID#") />
<cfif SurveyPopupDisplayChek EQ 1>
	<script> NewWindow('/survey/SurveyAlert.cfm','BlacksmithSurveyPopup','400','300','No','No'); </script>
</cfif>

<CFOUTPUT>
<table border="0" cellpadding="2" cellspacing="0" width="100%" ALIGN="center">
<!---
	<tr>
		<TD STYLE="color: white; font-size:10px;" nowrap align="right" colspan="5">
			<div id="google_translate_element"></div>
			<script type="text/javascript">
			function googleTranslateElementInit() {
			  new google.translate.TranslateElement({pageLanguage: 'en', includedLanguages: 'en,fr', layout: google.translate.TranslateElement.InlineLayout.SIMPLE}, 'google_translate_element');
			}
			</script>
			<script type="text/javascript" src="//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit"></script>
		</TD>
	</tr>
 --->
  <tr>
    <td rowspan="5" width="40%" VALIGN="top">

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
				<TD rowspan="2" ALIGN="center" VALIGN="top"><BR><IMG SRC="/images/round_programs.gif" WIDTH="55" HEIGHT="55" ALT="" BORDER="0"></TD>
				<TD COLSPAN="2" WIDTH="100%" STYLE="border-bottom: 2px solid ##aaaa00"><BR><B>Programs</B></TD>
			</TR>
			<TR>
				<TD <!--- WIDTH="50%" --->>
					<CFIF createProgramAccess>
						<A HREF="##" TITLE="create a new program" OnClick="CallJS()">Create program</A><BR>
					</CFIF>

					<CFIF ABS(Get_Profile_Settings.Cont_Prog_View_Create_Program) EQ 1>
						<!--- Dev Note: drachala; D29074 : Add option to program search to allow user to search on GL Account  START
                        Added/Changed: Added new IF conditions to displayin links--->
						<cfif appSettings.getFlexProgramSearch() EQ 1>
							<A HREF="/Scorecard/program_Search.cfm?type=html" TITLE="search for a program">Search program</A><BR>
						<cfelseif appSettings.getFlexProgramSearch() EQ 2>
							<A HREF="/flex/search/ProgramSearchFx.cfm" TITLE="search for a program">Search program</A><BR>
						<cfelseif appSettings.getFlexProgramSearch() EQ 3>
							<A HREF="/Scorecard/program_Search.cfm?type=html&searchType=1&fromHomePage=1" TITLE="search for a program">Advance Program Search </A> <BR>
							<A HREF="/flex/search/ProgramSearchFx.cfm" TITLE="search for a program">Program Search </A><BR>
						</cfif>
						<!--- End Dev Note: drachala; D29074: Add option to program search to allow user to search on GL Account  --->
					</CFIF>

					<!--- (Start) Only if the Export Program App Setting is turned on --->
					<cfif appSettings.getShowExportPrograms()>
						<CFIF ABS(Get_Profile_Settings.Create_Export_Agreements) EQ 1 OR ABS(Get_Profile_Settings.Create_Approve_Export_Agreements) EQ 1>
							<A HREF="/common_files/sales_agreement_select_new_program_type.cfm" TITLE="create a new program">Create export program</A><BR>
						</CFIF>

						<CFIF ABS(Get_Profile_Settings.Create_Export_Agreements) EQ 1 OR ABS(Get_Profile_Settings.Approve_Export_Agreements) EQ 1 OR ABS(Get_Profile_Settings.Create_Approve_Export_Agreements) EQ 1>
							<A HREF="/Scorecard/sales_agreement_Search.cfm" TITLE="search for an export program">Search export program</A><BR>
						</CFIF>

						<CFIF ABS(Get_Profile_Settings.Create_New_Export_Customer) EQ 1>
							<A HREF="/common_files/contracts/sales_agreement_customer_request.cfm" TITLE="Create a new customer for export business">Create new export customer</A><BR>
						</CFIF>
					</cfif>
					<!--- (End) Only if the Export Program App Setting is turned on --->

					<!------ futures pricing ----->
					<cfif appSettings.getFuturesPricingAvailable()>
						<CFIF createProgramAccess>
							<A HREF="/Futures_Pricing/index.cfm" TITLE="futures pricing">Futures pricing</A><BR>
						</CFIF>
					 </cfif>

					<CFIF Get_Profile_Settings.Commodity_Settings EQ 1>
						<A HREF="/profits/index.cfm">Commodity costs</A><BR>
					</CFIF>

					<cfif appsettings.getapprovalmatrixoff() EQ 0>
						<CFIF Get_Profile_Settings.Cont_Prog_Approval_Rights EQ 1>
							<A HREF="/Common_Files/Margin_Matrix/index.cfm">Approval matrix</A><BR>
						</CFIF>
					</cfif>
				</TD>
				<TD VALIGN="Top">
					<cfif appsettings.gettradeplanneroff() EQ 0>
						<cfif ListFindNoCase("Pactiv,Lambweston",application.returned_customer_setting.customer_keyword) eq 0>
							<A HREF="/ReportWriter/trade_plan/index.cfm"  TITLE="#application.returned_customer_setting.Trade_Label# planner">#application.returned_customer_setting.Trade_Label# Planner</A><BR>
						</cfif>
					</cfif>
					<CFIF Get_Profile_Settings.Reassign_Program_Access EQ 1>
						<A HREF="/Common_Files/Contracts/Reassign_Programs.cfm" TITLE="reassign programs to a different user position">Reassign</A><BR>
					</CFIF>

					<CFIF usdanoi_on EQ 1>
						<a href="/settings/usdanoi/noi_usage_agreement.cfm">USDA NOI Search</a><BR>
					</CFIF>
					
					<A HREF="##" onClick="NewWindow('/flex/fitness.swf','eligibilityWin','1200','700','Yes', 'Yes');return false;" >Trade Eligibility Report</A><BR>
				</TD>
				<TD <!--- WIDTH="50%" --->VALIGN="Top">&nbsp;</TD>
			</TR>

			<cfset variables.billbackModule = application.appSettingsGet.getBillback_Module()>
			<!---<CFIF application.returned_customer_setting.show_billback EQ 1  --->
			<CFIF variables.billbackModule eq 1>
			<TR>
				<TD rowspan="2" ALIGN="center" VALIGN="top"><IMG SRC="/images/round_billbacks.gif" WIDTH="55" HEIGHT="55" ALT="" BORDER="0"></TD>
				<TD COLSPAN="2" WIDTH="100%" STYLE="border-bottom: 2px solid ##4169E1;"><B>Billbacks</B></TD>
			</TR>
			</CFIF>

			<TR>
				<TD VALIGN="top">
					<CFIF variables.billbackModule EQ 1 AND Get_Profile_Settings.BB_Create EQ 1 AND appSettings.getShowManualBillback()>
						<!---
								31505:	App setting for Flex BB Module/Anand Rao/24-Apr-2012
							  	If it is Flex then take to flex pages to create for all other take to older method
						--->
						<cfif appsettings.getBillbackModuleType() EQ 2>
							<A HREF="/flex/BillbackSearchFx.cfm">Create billback</A><BR>
						<cfelse>
							<A HREF="/billbacks/capture/index.cfm">Create billback</A><BR>
						</cfif>
					</CFIF>
					<CFIF appSettings.getShowAutoBillback()>
						<CFIF Get_Profile_Settings.BB_Create EQ 1>
							<cfif appSettings.getAutoBillBackType()>
								<A HREF="/billbacks/capture/INDEX.CFM?AUTOBB=2">Create Auto billback</A><BR>
							<cfelse>
								<A HREF="/billbacks/capture/INDEX.CFM?AUTOBB=1">Create Auto billback</A><BR>
							</cfif>
						</CFIF>
					</CFIF>
					<CFIF variables.billbackModule EQ 1 and ListFindNoCase("1,2", Get_Profile_Settings.BB_Create)>
						<!---
								31505:	App setting for Flex BB Module/Anand Rao/24-Apr-2012
							  	If it is CF then take to CF pages. For all others take to current method which is flex search.
						--->
						<cfif appsettings.getBillbackModuleType() EQ 1>
							<A HREF="/Billbacks/Scorecard/billback_Search.cfm?searchType=advanced">Advanced Search billbacks</A><BR>
							<A HREF="/Billbacks/Scorecard/billback_Search.cfm">Search billbacks</A><BR>
						<cfelse>
							<A HREF="/flex/BillbackSearchFx.cfm">Search billbacks</A><BR>
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
				</TD>
				<TD VALIGN="top">
					<CFIF variables.billbackModule EQ 1 AND appSettings.getView_Auto_Checkbook() IS 1>
						<A HREF="/billbacks/ledger/auto_checkbook/index.cfm">Auto checkbook</A><BR>
					</CFIF>
					<CFIF variables.billbackModule EQ 1 AND application.returned_customer_setting.customer_keyword IS "conagra" >
						<CFIF Get_Profile_Settings.Reimbursement_Update EQ 1>
							<A HREF="/billbacks/reimbursements/index.cfm">Reimbursements</A><BR>
						</CFIF>
					</CFIF>
					<!-----<cfif application.deductionLinksAvailable>--->
					<cfif application.appSettingsGet.getDeduction_Module()>
						<!------ Deduction code ----->
						<CFIF DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 0>
							<A HREF="/deductions/index.cfm">Deductions</A><BR>
						</cfif>
						<cfif appSettings.getDD_Show_reassign()>
							<CFIF DeductionsProfilesSettings.DD_Reassign_Access EQ 1 AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
								<A HREF="/deductions/Reassign/Bulk_DD_Reassign.cfm">Reassign Deductions</A><BR>
							</CFIF>
						</cfif>
					</cfif>
					<CFIF Get_Profile_Settings.DD_Match_Central eq 1>
						<A HREF="/MatchCentral/index_main.cfm?showSearch=true">Match Central</a><br />
					</CFIF>
					<cfif application.appSettingsGet.get_Setting('BB_Doc_Server_Folder') NEQ ''> <!--- <cfif appSettings.get_Setting('Deduction_Ship_To_Bill_To_Association_Required') neq '1'> --->
						<CFIF Get_Profile_Settings.Browse_BBDoc_Server_Files EQ 1>
							<A HREF="/common_files/Documents/BrowseBBDocsGet.cfm" onClick="NewWindow(this.href,'BrowseBBDocWin','810','600','Yes', 'No');return false;" >Browse BB Doc Server</A><BR>
						</CFIF>
					</CFIF>
					<CFIF variables.billbackModule EQ 1 AND Get_Profile_Settings.Vendor_Hold_Research eq 1>
						<a href="##" onclick="popupCenterByPercentages('/common_files/processing.cfm?actualPage=/billbacks/vendor_hold.cfm', 'vendor_hold_research', 94, 84)">Vendor Hold Research</a><br />
					</CFIF>
				</TD>
				<TD VALIGN="Top">&nbsp;</TD>
			</TR>

			<TR>
				<TD rowspan="2" ALIGN="center" VALIGN="top"><IMG SRC="/images/round_projects.gif" WIDTH="55" HEIGHT="55" ALT="" BORDER="0"></TD>
				<TD COLSPAN="2" WIDTH="100%" STYLE="border-bottom: 2px solid Red;"><B>Deployment</B></TD>
			</TR>
			<TR>
				<cfif ShowProjectsScoreCard>
					<TD VALIGN="TOP">
						<CFIF Get_Profile_Settings.PM_Access EQ 1>
							<a href="/ReportWriter/PM/PM_create.cfm">Create project</a><BR>
						</CFIF>
						<CFIF Get_Profile_Settings.PM_Access EQ 1>
							<a href="/ReportWriter/PM/index.cfm">Search projects</a><BR>
						</CFIF>
						<a href="/ReportWriter/PM/PM_Critical_Display.cfm" TITLE="view critical projects">Critical projects</a><BR>
						<CFIF Get_Profile_Settings.PM_Access EQ 1 AND Get_Profile_Settings.Reassign_Project_Access EQ 1>
							<a href="/ReportWriter/PM/Reassign/PM_Reassign.cfm">Reassign projects</a><BR>
						</CFIF>
					</TD>
				</cfif>
				<TD VALIGN="TOP">
				<CFIF Get_Profile_Settings.View_Invoices EQ 1>
					<a href="/search_screens/invoice/search_invoices.cfm" TITLE="search invoices">Invoices</a><BR>
				</CFIF>
				<!--- D42844: Operator search from Home Page/ Operator search was commented as per Discussion with Paul/12-May-2014 --->
				<!--- <a STYLE="cursor:pointer;" href="##" onclick="javascript:showoperators();" TITLE="search operators">Search #application.returned_customer_setting.operator_label_singular#</a><BR> --->

				<!---D26123 - Show volume forecast if profile permission is enabled--->
				<cfif Get_Profile_Settings.Volume_Forecast gt 0>
						<a href="/common_files/volume/listVF.cfm" title="Volume Forecast">Volume Forecast</a><br>
				</cfif>
				<cfif appSettings.getProfitabilityModel()>
					<a href="/profits/operator/index.cfm" title="">Operator Profit</a><br />
				</cfif>
				<CFIF Get_Profile_Settings.Redistribution EQ 1 and ShowProjectsScoreCard>
					<A HREF="##" onclick="NewWindow('/Flex/Redi.swf','redi','1200','768','Yes', 'Yes')">Redistribution</A><BR>
				</CFIF>
				<cfif appSettings.getProgramClaimRatesReportAvailable() AND ABS(Get_Profile_Settings.Cont_Prog_View_Create_Program) EQ 1>
					<a href="/ReportWriter/program_claim_rates_report.cfm" title="">Claim Rates</a> <br/>
				</cfif>
				<cfif Get_Profile_Settings.What_If_From_Scratch eq 1>
					<a href="/common_files/whatif/list_what_if.cfm">What If P&L</a><BR>
				</cfif>
				</TD>

				<TD VALIGN="Top">
					<CFIF Get_Profile_Settings.Redistribution EQ 1 and not ShowProjectsScoreCard>
						<A HREF="##" onclick="NewWindow('/Flex/RediFx.cfm','redi','1200','768','Yes', 'Yes')">Redistribution</A><BR>
					</CFIF>
					&nbsp;
				</TD>
			</TR>
			<TR>
				<TD rowspan="2" ALIGN="center" VALIGN="top"><IMG SRC="/images/round_settings.gif" WIDTH="55" HEIGHT="55" ALT="" BORDER="0"></TD>
				<TD COLSPAN="2" WIDTH="100%" STYLE="border-bottom: 2px solid Green;"><B>Tools</B></TD>
			</TR>
			<TR>
				<TD>
					<CFIF Get_Profile_Settings.Settings_Panel GT 0>
						<a href="/settings/index2.cfm">Settings</a><BR>
					</CFIF>
					<!--- MOVED TO REPORTS CENTRAL mws --->
					<!--- <CFIF application.InvoiceReportsLinksAvailable EQ 1><a href="/ReportWriter/reportInvoice.cfm">Volume Reports</a><BR></CFIF> --->
					<CFIF application.personalization EQ 1>
						<A HREF="/settings/personalization/index.cfm">Personalization</a><BR>
					</CFIF>
							<!--- MOVED TO REPORTS CENTRAL mws --->
							<!--- <a href="/Common_Files/Performance_Indicators/progPerfIndicator.cfm">Performance Indicators</a><BR> --->
							<!--- <a href="/reportWriter/claimsIndex.cfm">Claim Reports</a><BR> --->
						<A HREF="/ReportWriter/index_main.cfm">Reports Central</a><br />
							<!--- <a href="/ReportWriter/ContractApproval/Periodical_Reports.cfm">Contract Approval Reports</a><BR> --->
					<CFIF Get_Profile_Settings.Clause_Library_Access EQ 1>
						<A HREF="/Clause_Library/index.cfm" TITLE="Clause Library">Clause Library</A><BR>
					</CFIF>
					<!--- Dev Note: KAL; 6/15/2010; D21554: LDAP Authentication - Dont show password option when LDAP is on --->
					<cfif NOT (appSettings.getLDAP_SSO_Enabled() or request.AccessStructure.SSO_User) >
						<A HREF="##" onClick="NewWindow('/settings/password_form.cfm?PageTitle=Personal%20Settings:%20change%20password&FromHome=1','name','825','375','Yes', 'Yes')">Change password</a><BR>
					</cfif>
					<cfif appSettings.getApprovalViaEmail()>
						<A HREF="##" onClick="NewWindow('/settings/pin_form.cfm','name','800','375','Yes', 'Yes')">Change pin</a><BR>
					</cfif>
						<A HREF="/BrowserSettings/index.cfm">Browser settings</A><BR>
					<CFIF application.returned_customer_setting.show_news EQ 1>
						<A HREF="/News_Ticker/Headlines/index.cfm">News headlines</A><BR>
					</CFIF>
					<cfif appSettings.getCrucibleOn() AND qGetUser.Crucible_File_Download EQ 1>
						<A HREF="/Crucible/index.cfm">GAUGE<SUP style="font-size:10px">SM</SUP></A><BR>
					</cfif>

			   </TD>
			   <TD VALIGN="top">
			   		<!--- DEV NOTE: DAA; D14743 <A HREF="/help_files/Whatsnew/index.cfm">What's new...</A><BR> --->
			   		<!--- DEV NOTE: DAA; D14743 ---><A HREF="##" onclick="NewWindow('/common_files/about.cfm','about','640','480','Yes', 'Yes')">About</A><BR>
					<cfif appSettings.getOnePageClaimForm()>
						<A HREF="/billbacks/ClaimForm/bin/ClaimForm.html">One Page Claim Form</A><BR>
					</cfif>


					<!--- ----------------------------------------------------------------------------------------- --->
					<!--- message center entry																	 	--->
					<!--- ----------------------------------------------------------------------------------------- --->
					<cfif Get_Profile_Settings.Message_Center_Viewing EQ 1>
					<A HREF="/messagecenter/index.cfm?id=94451-84537-17189-37328">Message Center</A><BR><br/>
					</cfif>
					<!--- ----------------------------------------------------------------------------------------- --->
					<!--- ----------------------------------------------------------------------------------------- --->
					<!--- ----------------------------------------------------------------------------------------- --->


					<!--- <CFIF Get_Profile_Settings.Redistribution EQ 1>
						<A HREF="##" onclick="NewWindow('/Flex/Redi.swf','redi','1200','768','Yes', 'Yes')">Redi</A><BR>
					</CFIF> --->

					<cfif appSettings.getsinglesign_on() eq 2>
						<a href="javascript:addbookmark()">Bookmark</a>
					</cfif>
				</TD>
				<TD VALIGN="Top">&nbsp;</TD>
			</TR>
		</TABLE>


	</td>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Set the height of the Iframes --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Based on whether we have the projects scorecard or not, I changed the size of the frame accordingly to remove the scrollbar --->
	<cfif ShowProjectsScoreCard eq 1>
		<CFSET iframeheight=225>
	<cfelse>
		<CFSET iframeheight=210>
	</cfif>
	<CFSET Temp_Scorecard_Width = (2.175 * iframeheight)>
	<CFSET TD_Pro_Height = Temp_Scorecard_Width + 6>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<TD VALIGN="Top" ALIGN="Center">
		<TABLE CELLSPACING="0" CELLPADDING="2" BORDER="0" WIDTH="326">
		<cfif ShowProjectsScoreCard eq 1>
			<TR>
				<TD <CFIF ABS(Get_Profile_Settings.Cont_Prog_View_Create_Program) EQ 1>CLASS="scorecardtitlebackground"<CFELSE>CLASS="scorecardtitlebackgrounddisabled"</CFIF>><CFIF ABS(Get_Profile_Settings.Cont_Prog_View_Create_Program) EQ 1><cfif appSettings.getFlexProgramSearch()><A HREF="/flex/search/ProgramSearchFx.cfm"><cfelse><A HREF="/Scorecard/program_Search.cfm"></cfif><IMG SRC="/Images/icon_search_small.gif" TITLE="Search for programs" WIDTH="19" HEIGHT="19" BORDER="0" ALIGN="right"></A></CFIF><DIV CLASS="scorecardtitletext">&nbsp;&nbsp;Programs Scorecard</DIV></TD>
			</TR>
			<TR>
				<TD VALIGN="Middle" HEIGHT="200" ALIGN="Center"<CFIF ABS(Get_Profile_Settings.Cont_Prog_View_Create_Program) EQ 1>onMouseOver="CellOn(this)" onMouseOut="CellOff(this)"</CFIF>><IFRAME SRC="/scorecard/index.cfm?a=#createuuid()#" WIDTH="320" HEIGHT="#iframeheight#" FRAMEBORDER="0" CLASS="scorecard"></IFRAME></TD>
			</TR>
			<TR>
				<TD HEIGHT="9"></TD>
			</TR>
				<TD <CFIF variables.billbackModule EQ 1 AND ListFindNoCase("1,2", Get_Profile_Settings.BB_Create)>CLASS="scorecardtitlebackground"<CFELSE>CLASS="scorecardtitlebackgrounddisabled"</CFIF>><CFIF variables.billbackModule EQ 1 AND ListFindNoCase("1,2", Get_Profile_Settings.BB_Create)><cfif appsettings.getBillbackModuleType() EQ 1><A HREF="/Billbacks/Scorecard/billback_Search.cfm"><cfelse><A HREF="/flex/BillbackSearchFx.cfm"></cfif><IMG SRC="/Images/icon_search_small.gif" TITLE="Search for billbacks" WIDTH="19" HEIGHT="19" BORDER="0" ALIGN="right"></A></CFIF><FONT COLOR="White"><DIV CLASS="scorecardtitletext">&nbsp;&nbsp;Billbacks Scorecard</DIV></TD>
			</TR>
				<CFSET iframeheight=180>
				<CFSET Temp_Scorecard_Width = (2.175 * iframeheight)>
				<CFSET TD_Pro_Height = Temp_Scorecard_Width + 6>
			<TR>
				<TD VALIGN="Middle" HEIGHT="170" ALIGN="Center" <CFIF variables.billbackModule EQ 1 AND ListFindNoCase("1,2", Get_Profile_Settings.BB_Create)>onMouseOver="CellOn(this)" onMouseOut="CellOff(this)"</CFIF>><IFRAME <CFIF variables.billbackModule EQ 1 AND ListFindNoCase("1,2", Get_Profile_Settings.BB_Create)>SRC="/billbacks/scorecard/scorecard_home.cfm?a=#createuuid()#"<cfelse>SRC="blank.html"</CFIF> WIDTH="320" HEIGHT="#iframeheight#" FRAMEBORDER="0" CLASS="scorecard"></IFRAME></TD>
			</TR>
		<cfelse> <!--- show programs scorecard in it's own column --->
		    <TR>
				<TD <CFIF ABS(Get_Profile_Settings.Cont_Prog_View_Create_Program) EQ 1>CLASS="scorecardtitlebackground"<CFELSE>CLASS="scorecardtitlebackgrounddisabled"</CFIF>><CFIF ABS(Get_Profile_Settings.Cont_Prog_View_Create_Program) EQ 1><cfif appSettings.getFlexProgramSearch()><A HREF="/flex/search/ProgramSearchFx.cfm"><cfelse><A HREF="/Scorecard/program_Search.cfm"></cfif><IMG SRC="/Images/icon_search_small.gif" TITLE="Search for programs" WIDTH="19" HEIGHT="19" BORDER="0" ALIGN="right"></A></CFIF><DIV CLASS="scorecardtitletext">&nbsp;&nbsp;Programs Scorecard</DIV></TD>
			</TR>
			<TR>
				<TD VALIGN="Middle" HEIGHT="#TD_Pro_Height#" ALIGN="Center"<CFIF ABS(Get_Profile_Settings.Cont_Prog_View_Create_Program) EQ 1>onMouseOver="CellOn(this)" onMouseOut="CellOff(this)"</CFIF>><IFRAME SRC="/scorecard/index.cfm?a=#createuuid()#" WIDTH="320" HEIGHT="#Temp_Scorecard_Width#" FRAMEBORDER="0" CLASS="scorecard"></IFRAME></TD>
			</TR>
		</cfif>
		</TABLE>
	</TD>
	<TD>&nbsp;</TD>
	<TD VALIGN="Top" ALIGN="Center">
		<TABLE CELLSPACING="0" CELLPADDING="2" BORDER="0" WIDTH="326">
		<cfif ShowProjectsScoreCard eq 1>
			<TR>
				<TD <CFIF Get_Profile_Settings.PM_Access EQ 1>CLASS="scorecardtitlebackground"<CFELSE>CLASS="scorecardtitlebackgrounddisabled"</CFIF>><CFIF Get_Profile_Settings.PM_Access EQ 1><a href="/ReportWriter/PM/index.cfm"><IMG SRC="/Images/icon_search_small.gif" TITLE="Search for projects" WIDTH="19" HEIGHT="19" BORDER="0" ALIGN="right"></a></CFIF><FONT COLOR="White"><DIV CLASS="scorecardtitletext">&nbsp;&nbsp;Projects Scorecard</DIV></TD>
			</TR>
			<TR>
				<TD VALIGN="Middle" ALIGN="Center" HEIGHT="#TD_Pro_Height#" <CFIF Get_Profile_Settings.PM_Access EQ 1>onMouseOver="CellOn(this)" onMouseOut="CellOff(this)"</CFIF>><IFRAME SRC="/ReportWriter/pm/PM_scorecard.cfm?a=#createuuid()#" WIDTH="320" HEIGHT="#Temp_Scorecard_Width#" FRAMEBORDER="0" CLASS="scorecard"></IFRAME></TD>
			</TR>
		<cfelse>
			</TR>
				<TD <CFIF variables.billbackModule EQ 1 AND ListFindNoCase("1,2", Get_Profile_Settings.BB_Create)>CLASS="scorecardtitlebackground"<CFELSE>CLASS="scorecardtitlebackgrounddisabled"</CFIF>><CFIF variables.billbackModule EQ 1 AND ListFindNoCase("1,2", Get_Profile_Settings.BB_Create)><cfif appsettings.getBillbackModuleType() EQ 1><A HREF="/Billbacks/Scorecard/billback_Search.cfm"><cfelse><A HREF="/flex/BillbackSearchFx.cfm"></cfif><IMG SRC="/Images/icon_search_small.gif" TITLE="Search for billbacks" WIDTH="19" HEIGHT="19" BORDER="0" ALIGN="right"></A></CFIF><FONT COLOR="White"><DIV CLASS="scorecardtitletext">&nbsp;&nbsp;Billbacks Scorecard</DIV></TD>
			</TR>
			<TR>
				<TD VALIGN="Middle" HEIGHT="#TD_Pro_Height#" ALIGN="Center" <CFIF variables.billbackModule  EQ 1 AND ListFindNoCase("1,2", Get_Profile_Settings.BB_Create)>onMouseOver="CellOn(this)" onMouseOut="CellOff(this)"</CFIF>><IFRAME <CFIF variables.billbackModule EQ 1 AND ListFindNoCase("1,2", Get_Profile_Settings.BB_Create)>SRC="/billbacks/scorecard/scorecard_home.cfm?a=#createuuid()#"<cfelse>SRC="blank.html"</CFIF> WIDTH="320" HEIGHT="#Temp_Scorecard_Width#" FRAMEBORDER="0" CLASS="scorecard"></IFRAME></TD>
			</TR>
		</cfif>
		</TABLE>
	</TD>
  </tr>



</table>
</CFOUTPUT>







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
		NewWindow('/reportwriter/performance_reports/revisionreport.cfm','ProgramRevisionDetails','850','550','Yes', 'Yes')
	}

	function showoperators()
	{
		NewWindow('/settings/operator_management/select_operators.cfm?searchoperator=1&SelectSingleSearchResultOnly=1','SearchOperators','850','550','Yes', 'Yes')
	}

	function addbookmark(){
    	window.external.AddFavorite('https://<CFOUTPUT>#CGI.HTTP_HOST#</CFOUTPUT>', parent.document.title);
	}

	<!--- Dev Note: Milan (22900). We open "Create program" page in a new window when Program Flex is On. --->
	function CallJS()
	{
		<cfif appSettings.getFlexProgramSearch()>
			window.open('/common_files/select_new_program_type.cfm','winSummary','height=768,width=1024,toolbar=no,scrollbars=yes,left=0,top=0,screenX=0,screenY=0,resizable=yes');
		<cfelse>
		window.location = '/common_files/select_new_program_type.cfm','winSummary','height=768,width=1024,toolbar=no,scrollbars=yes,left=0,top=0,screenX=0,screenY=0,resizable=yes';
		</cfif>
	}
</SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>
