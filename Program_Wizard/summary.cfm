<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<head>
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px;}
	#bigTable tr, #bigTable table tr { height:25px; }
	#bigTable th { text-align:left; border-bottom:1px solid black; font-weight:bold; font-size:14px; padding:10px 0 0 0;}
  .sr31 { display:inline-block; }
  .fc21 { padding-left:20px; }
  .sc73 { color:green; }
</style>
</head>
<body>
<!----
/Program_Wizard/index.cfm

Created By: Brenda Flynn
			bflynn@awayx.com
Created On: May 7, 2003
Modified By:
Last Modified On:
-----------------------------
Shows all the details for a program.
--->

<cfparam name="ViewOnly" default="0">

<!---Show discount identifier--->
<cfset useLakebaseForgetGeneralSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForgetGeneralSettings>
	<cftry>
		<cfset getGeneralSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"limit" = "1",
				"select" = "use_discount_id"
			}), "use_discount_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetGeneralSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetGeneralSettings>
<cfquery name="getGeneralSettings" datasource="#application.datasource#">
SELECT TOP 1 Use_Discount_ID
FROM General_Settings
</cfquery>
</cfif>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
<cfset LabelComp = Createobject("component", "components.settings.labels.labels").init() />

<cfset SPA = CreateObject("component","components.user.settingsPanelAccess").init() />
<cfset getSPA = SPA.getSPAccess()>

<cfif IsDefined("url.ID")>
	<cfset ID = url.ID>
<cfelseif IsDefined("form.ID")>
	<cfset ID = form.ID>
<cfelse>
	<cfset ID = 0>
</cfif>

<cfset template = templateManager.get(id)>

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">


<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<CFIF Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 0>
	<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
</CFIF>

<cfset PAGE_TITLE = "Program Type Summary">

<!--- <html>
<head> --->
<cfif ViewOnly IS 0>
<CFSET PAGETITLE = "PROGRAM TEMPLATES: SUMMARY">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
</cfif>

<!---Get all information on a Program Type--->
<cfquery name="GetAllInfo" datasource="#application.datasource#">
	SELECT	Program_Control_Panel_Options.*,_Users.Name_First, _Users.Name_Last
	FROM _Users INNER JOIN Program_Control_Panel_Options
	ON _Users.User_ID = Program_Control_Panel_Options.Updated_By
	WHERE 	ProgramControl_Panel_Options_ID = #ID#
</cfquery>

<!--- <body leftmargin="0" topmargin="0" bottommargin="0" rightmargin="0">

<cfinclude template="/includes/header.cfm"> --->
<!---
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;<B>
<FONT SIZE="2" COLOR="Red">[</FONT>
<FONT SIZE="2" COLOR="Blue"><A HREF="/help_files/manual/CreateProgram/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;">read me first</A></FONT>
<FONT SIZE="2" COLOR="Red">]</FONT>
</B>

<center>
<BR> --->

<CFOUTPUT>
<div align="Center" class="labelname">#GetAllInfo.Created_Type# (#ReReplaceNoCase(GetAllInfo.Generic_Type, "trade", application.returned_customer_setting.Trade_Label)#)</div><div align="Center" class="labelname"><cfif ViewOnly IS 0><cfif GetAllInfo.Active IS 1>ACTIVE<cfelse> NOT ACTIVE</cfif></cfif></div>

<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="7" ALIGN="CENTER" STYLE="border:2px orange solid;margin-top:5px;">
	<TR>
	<TD STYLE="font-weight:bold;font-size:13px;">This setting was last updated on #DateFormat(GetAllInfo.Date_Updated, "mm/dd/yyyy")# #TimeFormat(GetAllInfo.Date_Updated, "hh:mm:ss tt")# by #GetAllInfo.Name_First#  #GetAllInfo.Name_Last#</TD>
	</TR>
</TABLE>
</CFOUTPUT>

<TABLE CELLPADDING="10" CELLSPACING="20" border="0" align="Center" width="85%" id="bigTable">
<cfoutput query="GetAllInfo">
<tr><td width="50%" valign="top">

	<table width="100%" cellpadding="1" cellspacing="0" border="0" class="inputTable">
  <col width="60%"> <col width="40%">
<tr><th colspan="2">Basic Information</th></tr>

	<!----Always show program name--->
	<tr>
		<td>Program Type Name</td>
		<td>#Created_Type#</td>
	</tr>

	<!---Always show description--->
	<tr>
		<td>Program Type Description</td>
		<td>#Program_Description#</td>
	</tr>

	<!---Show Discount Identifier if it's turned on and there is one--->
	<cfif getGeneralSettings.Use_Discount_ID IS 1 AND len(trim(GetAllInfo.Discount_Identifier_ID)) GT 0>
	<cfset useLakebaseForGetDIInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("discount_identifier")>
<cfif useLakebaseForGetDIInfo>
	<cftry>
		<cfset GetDIInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("discount_identifier", {
				"discount_identifier_id" = "eq.#GetAllInfo.Discount_Identifier_ID#",
				"select" = "discount_identifier_number,discount_identifier_desc"
			}), "discount_identifier_number,discount_identifier_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDIInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDIInfo>
<cfquery name="GetDIInfo" datasource="#application.datasource#">
	SELECT Discount_Identifier_Number, Discount_Identifier_Desc
	FROM Discount_Identifier
	WHERE Discount_Identifier_ID = '#GetAllInfo.Discount_Identifier_ID#'
	</cfquery>
</cfif>
		<tr>
		<td>Discount Identifier</td>
		<td>#GetDIInfo.Discount_Identifier_Desc# (#GetDIInfo.Discount_Identifier_Number#)</td>
	</tr>
	</cfif>

	<!---Include or exclude trade?--->

	<!----Show others only if they're included--->
	<tr>
		<td>Includes Trade </td>
		<td><Cfif Include_Trade IS 0>No<cfelse>Yes</CFIF> </td>
	</tr>

	<!---Trade Blurb--->
	<cfif len(trim(Trade_Blurb)) GT 0>
	<tr>
		<td>#Trade_Blurb#</td>
		<td></td>
	</tr>
	</cfif>

	<!---Duration Maximum--->
	<cfif Max_Duration IS 1>
	<tr>
		<td>Maximum Duration</td>
		<td>#Max_Duration_Length#</td>
	</tr>
	</cfif>

	<!---Duration Minimum--->
	<cfif Min_Duration IS 1>
	<tr>
		<td>Minimum Duration</td>
		<td>#Min_Duration_Length#</td>
	</tr>
	</cfif>

	<!---Maximum Volume--->
	<cfif Max_Global_Volume IS 1>
	<tr>
		<td>Maximum Volume:</td>
		<td>#Max_Global_Volume_Size_CS# Cases &nbsp; &nbsp; #Max_Global_Volume_Size_LBS# Pounds</td>
	</tr>
	</cfif>

	<!---Minimum Volume--->
	<cfif Min_Global_Volume IS 1>
	<tr>
		<td>Minimum Volume</td>
		<td>#Min_Global_Volume_Size_CS# Cases  &nbsp; &nbsp; #Min_Global_Volume_Size_LBS# Pounds</td>
	</tr>
	</cfif>

	<!---Minimum Lumpsum--->
	<cfif len(trim(Min_Lump_Sum)) GT 0 AND Min_Lump_Sum NEQ 0>
	<tr>
		<td>Minimum #Application.LumpsumLabel#</td>
		<td>#lscurrencyformat(Min_Lump_Sum)# </td>
	</tr>
	</cfif>

	<!---Maximum Lumpsum--->
	<cfif len(trim(Max_Lump_Sum)) GT 0 AND Max_Lump_Sum NEQ 0>
	<tr>
		<td>Maximum #Application.LumpsumLabel#</td>
		<td>#lscurrencyformat(Max_Lump_Sum)#</td>
	</tr>
	</cfif>


	<!---Allows Retroactive--->
	<cfif Allow_Retro_Create IS 1>
	<tr>
		<td>Retroactive Programs</td>
		<td>#Allow_Retro_Create_Max# days retroactive </td>
	</tr>
	</cfif>

	<!---Allows Retroactive Revisions--->
	<cfif Allow_Retro_Revision IS 1>
	<tr>
		<td>Retroactive Revisions</td>
		<td>#Allow_Retro_Revision_Span# days retroactive </td>
	</tr>
	</cfif>

	<!---Allows Negative Off-Invoice--->
	<cfif No_Negative_OI IS 1>
	<tr>
		<td>Forbids negative Off-Invoice</td>
		<td></td>
	</tr>
	</cfif>

	<!---Billback expiration--->
	<cfif Billback_Date IS 1 AND len(trim(Billback_Date_Span)) GT 0>
	<tr>
		<td>Last Date to Claim</td>
		<td>#Billback_Date_Span# days after program end </td>
	</tr>
	</cfif>

	<!---Auto Renew--->
	<cfif Auto_Renew_Option IS 1>
	<tr>
		<td colspan="2">Auto Renewable <cfif Auto_Renew_Option IS 1 AND appSettings.AutoRenewSpaninPW IS 1 AND Allow_AR_Modification IS 1>(user can modify)</cfif></td>
	</tr>
	</cfif>

	<!---Auto Renew span--->
	<cfif Auto_Renew_Option IS 1 AND appSettings.AutoRenewSpaninPW IS 1>
	<tr>
		<td>Days before expiration to auto renew</td>
		<td>#Days_Before_Auto_Renew# </td>
	</tr>
	</cfif>

	<!---Reminder days--->
	<tr>
		<td>Days after RFA to remind</td>
		<td>#Days_for_Reminder# </td>
	</tr>

	<!---Mark as expiring--->
	<tr>
		<td>Weeks before end of program to mark as expiring</td>
		<td>#Expiring_Notification_Span# </td>
	</tr>

	<!---Includes Payable To--->
	<cfif Payable_To IS 1>
	<tr>
		<td>Includes Payable To </td>
		<td><cfif Payable_To_Required IS 1>(required)<cfelse>(not required)</cfif></td>
	</tr>
	</cfif>

	<!---Includes Send Payment To--->
	<cfif Send_Payment_To IS 1>
	<tr>
		<td>Includes Send Payment To </td>
		<td><cfif Send_Payment_To_Required IS 1>(required)<cfelse>(not required)</cfif></td>
	</tr>
	</cfif>


	<!---Customer Acceptance--->
	<cfif Customer_Acceptance IS 1>
	<tr>
		<td>Includes Customer Acceptance fields</td>
		<td></td>
	</tr>
	</cfif>

	<!---Allows Advanced Spending--->
	<cfif Adv_Spend IS 1>
	<tr>
		<td>Allows Advanced Spending</td>
		<td></td>
	</tr>
	</cfif>

	<!---Allows Zero volume--->
	<cfif Zero_Volume IS 1>
	<tr>
		<td>Allows Zero Volume</td>
		<td></td>
	</tr>
	</cfif>

	<!---Controllable--->
	<cfif Controllable_Volume IS 1>
	<tr>
		<td>Controllable Volume</td>
		<td></td>
	</tr>
	</cfif>

	<!---Specify Distributors--->
	<cfif Specify_Distributors IS 1>
	<tr>
		<td>#application.returned_customer_setting.distributor_label_plural# Option</td>
		<td><cfif Require_Distributor IS 1>Required</cfif>&nbsp; <cfif One_Distributor IS 1>(One only)</cfif></td>
	</tr>
	</cfif>

	<!---Specify Distributor Groups--->
	<cfif isDefined("Specify_Distributor_Groups") and Specify_Distributor_Groups IS 1>
		<tr>
			<td>#application.returned_customer_setting.distributor_label_singular# Groups Option</td>
			<td>&nbsp;</td>
		</tr>
	</cfif>

	<!----Dynamic Groups--->
	<cfif isDefined("Dynamic_Static_Groups")>
		<tr>
			<td>#IIf(Dynamic_Static_Groups eq 0, DE("Static"), DE("Dynamic"))# Groups</td>
			<td>&nbsp;</td>
		</tr>
	</cfif>

	<!---Specify Operators--->
	<cfif Specify_Operators IS 1>
	<tr>
		<td>#application.returned_customer_setting.operator_label_plural# Option</td>
		<td><cfif Require_Operator IS 1>Required</cfif>&nbsp; <cfif One_Operator IS 1>(One only)</cfif></td>
	</tr>
	</cfif>

	<!---Specify Brokers--->
	<cfif Specify_Brokers IS 1>
	<tr>
		<td>Brokers Option</td>
		<td><cfif Generic_Type EQ "LSAutoPay">(One only)<cfelse>&nbsp;</cfif></td>
	</tr>
	</cfif>

	<!---One discount type required--->
	<cfif One_Discount_Mandated IS 1>
	<tr>
		<td>Must include at least one discount</td>
		<td></td>
	</tr>
	</cfif>

	<!---Equipment Placement--->
	<cfif Equipment_Placement IS 1>
	<tr>
		<td>Equipment and Dispenser Placement</td>
		<td></td>
	</tr>
	</cfif>

	<!--- Allow Add All Products --->
	<tr>
		<td>Allow Add All Products</td>
		<td><cfif Allow_Add_All_Products IS 1>Yes<cfelse>No</cfif></td>
	</tr>

	<cfif Date_Exclusions_ON IS 1>
	<tr>
		<td>Date Exclusions Enabled</td>
		<td>Yes</td>
	</tr>
	</cfif>
	<!--- D8409: Broker and Trade Question --->
	<cfif appSettings.getBrokerTradeQuestOn() EQ 1>
	<tr>
		<td>Enable Broker and Trade Questions</td>
		<td><cfif Broker_Trade_Question EQ 1>Yes<cfelse>No</cfif></td>
	</tr>
	</cfif>

	<!--- Price Protection --->
	<cfif Generic_Type IS  "Operator Direct or HQ Programs" or Generic_Type IS  "Operator-Deviated Pricing">
		<tr>
		<td>Price Protection On</td>
		<td><cfif price_protection_on EQ 1>Yes<cfelse>No</cfif></td>
	</tr>
	</cfif>

	<cfif appSettings.getPullbacksOn() EQ 1>
	<tr>
		<td>Pullbacks On</td>
		<td><cfif Pullbacks_On EQ 1>Yes<cfelse>No</cfif></td>
	</tr>
	</cfif>
	<tr>
		<td>Apply Rebate Rates</td>
		<td><cfif apply_rebate_rates EQ 1>Yes<cfelse>No</cfif></td>
	</tr>
	<cfif appsettings.getMass_Pay_Billback()>
	<tr>
		<td>Allow mass payment of billbacks</td>
		<td><cfif mass_billback_pay EQ 1>Yes<cfelse>No</cfif></td>
	</tr>
	</cfif>

	<cfif appsettings.getDisplayInterfaceFlagsSet1()>
	<tr>
		<td>Include in deals interface</td>
		<td><cfif Include_Template_In_Deals_IF EQ 1>Yes<cfelse>No</cfif></td>
	</tr>
	</cfif>

	<cfif appsettings.getOperatingGroupOn()>
	<tr>
		<td>Include treatment code and basis code</td>
		<td><cfif Include_Treatment_Basis_Code EQ 1>Yes<cfelse>No</cfif></td>
	</tr>
	<tr>
		<td>Exclude same spending category programs from TPA</td>
		<td><cfif Exclude_Same_Spending_Cat_From_TPA EQ 1>Yes<cfelse>No</cfif></td>
	</tr>
	</cfif>
	<!--- Retail Performance Dates --->
	<cfset PerformanceDatesLabel 	= labelComp.GetGeneralLabels('Performance Dates').General_Labels_Label />
	<tr>
		<td>#PerformanceDatesLabel# On </td>
		<td><Cfif Retail_Performance_Dates IS 0> No <cfelse> Yes</CFIF> </td>
	</tr>
	<!----Rate Types--->

	<cfif Generic_Type IS NOT "Distributor Off-Invoice">
  <tr><th colspan="2">Rate Types</th></tr>

	<!---Per Pound--->
	<cfif RateTypeOption_1 IS 1>
	<tr>
		<td>Per Pound</td>
		<td><cfif RateTypeDefault IS 2>Default</cfif></td>
	</tr>
	</cfif>

	<!---Per Case--->
	<cfif RateTypeOption_2 IS 1>
	<tr>
		<td>Per Case</td>
		<td><cfif RateTypeDefault IS 1>Default</cfif></td>
	</tr>
	</cfif>

	<!---Percent--->
	<cfif RateTypeOption_3 IS 1>
	<tr>
		<td>Percent</td>
		<td><cfif RateTypeDefault IS 3>Default</cfif></td>
	</tr>
	</cfif>

	<!---Payment Types--->

	<tr><th colspan="2">Claim Mechanics</th></tr>

	<!---Get payment types--->
	<cfquery name="GetPaymentTypes" datasource="#application.datasource#">
	SELECT Payment_Type.Payment_Type_Name, Payment_Type.Payment_Type_ID
	FROM Payment_Type
		INNER JOIN Payment_Template_Mapping
		ON Payment_Template_Mapping.Template_ID = '#ID#'
		AND Payment_Type.Payment_Type_ID = Payment_Template_Mapping.Payment_Type_ID
		AND Payment_Template_Mapping.Deleted = 0
	WHERE Payment_Type.Deleted = 0
	ORDER BY Payment_Type.Payment_Type_Name
	</cfquery>

	<cfloop query="GetPaymentTypes">
	<tr>
		<td>#Payment_Type_Name#</td>
		<td><cfif GetAllInfo.ClaimMechDefaultOption IS Payment_Type_ID>Default</cfif></td>
	</tr>
	</cfloop>


		<!---Payment Paid To Types--->

  <tr><th colspan="2">Payments Paid To</th></tr>

	<!---Get payment types--->
	<cfquery name="GetPaymentPaidToTypes" datasource="#application.datasource#">
	SELECT 	Payment_Paid_To_Types.Payment_Paid_To_Type_Identifier, Payment_Paid_To_Types.Payment_Paid_To_Type_Name, Payment_Paid_To_Types.Payment_Paid_To_ID
	FROM 	Payment_Paid_To_Types
	INNER JOIN Payment_Paid_To_Template_Mapping
	ON 		Payment_Paid_To_Template_Mapping.Template_ID = '#ID#'
	AND 	Payment_Paid_To_Types.Payment_Paid_To_ID = Payment_Paid_To_Template_Mapping.Payment_Paid_To_ID
	AND 	Payment_Paid_To_Template_Mapping.Deleted = 0
	WHERE 	Payment_Paid_To_Types.Deleted = 0
	ORDER BY Payment_Paid_To_Types.Payment_Paid_To_ID
	</cfquery>

	<cfloop query="GetPaymentPaidToTypes">
	<tr>
		<td>#templateManager.getPaymentPaidToTypeDesc(paidToTypeIdentifier = Payment_Paid_To_Type_Identifier, paidToDesc=Payment_Paid_To_Type_Name)#</td>
		<td>&nbsp;</td>
	</tr>
	</cfloop>

	<!---Payment Cycle--->

  <tr><th colspan="2">Payment Cyle</th></tr>

	<!---Daily--->
	<cfif PayCycleOption_1 IS 1>
	<tr>
		<td>Daily</td>
		<td><cfif PayCycleDefaultOption IS 1>Default</cfif></td>
	</tr>
	</cfif>

	<!---Weekly--->
	<cfif PayCycleOption_2 IS 1>
	<tr>
		<td>Weekly</td>
		<td><cfif PayCycleDefaultOption IS 2>Default</cfif></td>
	</tr>
	</cfif>

	<!---Monthly--->
	<cfif PayCycleOption_3 IS 1>
	<tr>
		<td>Monthly</td>
		<td><cfif PayCycleDefaultOption IS 3>Default</cfif></td>
	</tr>
	</cfif>

	<!---Quartly--->
	<cfif PayCycleOption_4 IS 1>
	<tr>
		<td>Quarterly</td>
		<td><cfif PayCycleDefaultOption IS 4>Default</cfif></td>
	</tr>
	</cfif>

	<!---Semi_Annual--->
	<cfif PayCycleOption_5 IS 1>
	<tr>
		<td>Semi Annually</td>
		<td><cfif PayCycleDefaultOption IS 5>Default</cfif></td>
	</tr>
	</cfif>

	<!---Annual--->
	<cfif PayCycleOption_6 IS 1>
	<tr>
		<td>Annually</td>
		<td><cfif PayCycleDefaultOption IS 6>Default</cfif></td>
	</tr>
	</cfif>

	<!---Upon Expiration--->
	<cfif PayCycleOption_7 IS 1>
	<tr>
		<td>Upon Expiration</td>
		<td><cfif PayCycleDefaultOption IS 7>Default</cfif></td>
	</tr>
	</cfif>

	<!---Upon Due--->
	<cfif PayCycleOption_8 IS 1>
	<tr>
		<td>Upon Due</td>
		<td><cfif PayCycleDefaultOption IS 8>Default</cfif></td>
	</tr>
	</cfif>

	<!---One Time Payment--->
	<cfif PayCycleOption_9 IS 1>
	<tr>
		<td>One Time Payment</td>
		<td><cfif PayCycleDefaultOption IS 9>Default</cfif></td>
	</tr>
	</cfif>

	<!---Fiscal Month--->
	<cfif PayCycleOption_10 IS 1>
	<tr>
		<td>Fiscal Month</td>
		<td><cfif PayCycleDefaultOption IS 10>Default</cfif></td>
	</tr>
	</cfif>

	<!---Fiscal Quarter--->
	<cfif PayCycleOption_11 IS 1>
	<tr>
		<td>Fiscal Quarter</td>
		<td><cfif PayCycleDefaultOption IS 11>Default</cfif></td>
	</tr>
	</cfif>

	<!---Don't show if its off-invoice--->
	</cfif>

		<!---Accounting Program Types--->
		<cfif appSettings.getUse_Accounting_Program_Type() EQ 1>

		<cfquery name="GetAccountingProgramTypes" datasource="#application.datasource#">
		SELECT Accounting_Program_Type.APT_Name, Accounting_Program_Type.APT_Reference_Number, Accounting_Program_Type.APT_Use_For_TPA
		FROM APT_Template_Mapping
			INNER JOIN Accounting_Program_Type
			ON 		Accounting_Program_Type.Accounting_Program_Type_ID = APT_Template_Mapping.Accounting_Program_Type_ID
			AND 	Accounting_Program_Type.Deleted = 0
			AND 	Accounting_Program_Type.Active = 1
		WHERE 	APT_Template_Mapping.Template_ID = '#ID#'
		AND		Accounting_Program_Type.Deleted = 0
		</cfquery>

    <tr><th colspan="2">Program Labels</th></tr>

		<cfset qLabels = createObject("component", "components.settings.Labels.Labels").init()>
		<cfset getProgramLabelSetNames = qLabels.GetProgramLabelSetNames(ID)>
		<cfloop query="getProgramLabelSetNames">
			<tr>
				<td>Label Set</td>
				<td><cfif Label_Set_Name NEQ "" OR Label_Set_Name NEQ NULL>#Label_Set_Name#<cfelse><em>none</em></cfif></td>
			</tr>
		</cfloop>

		<cfloop query="GetAccountingProgramTypes">
		<tr>
			<td valign="top" style="border-bottom:solid ##93BEE2 1px;" colspan="2">#APT_Name# <cfif len(trim(APT_Reference_Number)) GT 0>(#APT_Reference_Number#)</cfif><br>
			<cfif APT_Use_For_TPA IS 0>Do not u<cfelse>U</cfif>se for margin calculation
			</td>
		</tr>
		</cfloop>
		</cfif>
		<!--- Dev Note: Milan - 6321 --->
		<cfif appSettings.getProgramCategory() eq 1>
		<cfset qGetProgramCategories = templateManager.getProgramCategories(ID)>
    <tr><th colspan="2">Program Categories</th></tr>

		<cfloop query="qGetProgramCategories">
		<tr>
			<td>#Program_Category#</td>
			<td>&nbsp;</td>
		</tr>
		</cfloop>
	</cfif>
		<!--- End Note: Milan - 6321 --->
		<cfif appSettings.getapprovalStandardOn()>
  <tr><th colspan="2">Approval Metrics</th></tr>
	<tr>
		<td>Margin per item</td>
		<td><cfif GetAllInfo.approval_margin_item EQ 1><img src="/Images/yes_small.gif"><cfelse><img src="/Images/no_small.gif"></cfif></td>
	</tr>
	<tr>
		<td>Spend per item</td>
		<td><cfif GetAllInfo.approval_spend_item EQ 1><img src="/Images/yes_small.gif"><cfelse><img src="/Images/no_small.gif"></cfif></td>
	</tr>
	<tr>
		<td>Program Margin</td>
		<td><cfif GetAllInfo.approval_program_margin EQ 1><img src="/Images/yes_small.gif"><cfelse><img src="/Images/no_small.gif"></cfif></td>
	</tr>
	<tr>
		<td>Program Spend</td>
		<td><cfif GetAllInfo.approval_program_spend EQ 1><img src="/Images/yes_small.gif"><cfelse><img src="/Images/no_small.gif"></cfif></td>
	</tr>
	<tr>
		<td>UOM for Margins</td>
		<td><cfif GetAllInfo.approval_uom EQ 1>CS<cfelse>LB</cfif></td>
	</tr>
	</cfif>

	</table>
	</td>

	<!-------Midspan------->
	<cfif Generic_Type IS NOT "Distributor Off-Invoice">
	<td valign="top" width="50%">

	<table width="100%" cellpadding="1" cellspacing="0" border="0" class="inputTable">
	<col width="45%"> <col width="25%"> <col width="30%">
	<!---Discount Types--->
	<tr>
		<th id="header" colspan="2">Discount Types</th>
		<th align="right" id="header">Level</th>
	</tr>
	<!---fixed rebate grid --->

	<tr>
		<td>Fixed/#Application.RebateLabel# Grid</td>
		<cfif Fixed_Rebate_Grid_Option IS 1>
			<td>(included)</td>
		<cfelse>
			<td>(not included)</td>
		</cfif>
		<td>N/A</td>
	</tr>
	<!---Fixed Prices--->

	<tr>
		<td>Fixed Price</td>
		<cfif Discount_Fixed_Prices IS 1 and Fixed_Rebate_Grid_Option eq 0>
			<td>(included)</td>
		<cfelse>
			<td>(not included)</td>
		</cfif>
		<td>N/A</td>
	</tr>


	<!---Rebates--->
	<tr>
		<td>#Application.RebateLabel#</td>
		<cfif Discount_Rebates IS 1 and Fixed_Rebate_Grid_Option eq 0>
			<td>(included)</td>
		<cfelse>
			<td>(not included)</td>
		</cfif>
		<td>
			<cfif Discount_Rebates_Item_Level eq 1>Item</cfif>
			<cfif Discount_Rebates_Group_Level eq 1>&nbsp;Group</cfif>
		</td>
	</tr>

	<!---Lump Sums--->
	<tr valign="top">
		<td>#Application.LumpsumLabel#</td>
		<cfif Discount_Lump_Sums IS 1>
			<td>(included)</td>
		<cfelse>
			<td>(not included)</td>
		</cfif>
		<td>
			<cfif Discount_Lump_Sums_Item_Mandated eq 1>Required</cfif>
			<cfif Discount_Lump_Sums_Item_Level eq 1>Item</cfif>
			<cfif Discount_Lump_Sums_Group_Level eq 1>Group</cfif>
			<br>Product
			<cfif NOT Discount_Lump_Sums_Item_Mandated>not</cfif>
			Required
			<br>#application.returned_customer_setting.distributor_label_singular#
			<cfif NOT Discount_Lump_Sums_Distributor_Mandated>not</cfif>
			Required
		</td>
	</tr>

	<!---Growth--->

	<tr valign="top">
		<td>Growth</td>
		<cfif Discount_Growth IS 1>
			<td>(included)</td>
		<cfelse>
			<td>(not included)</td>
		</cfif>
		<td>
			<cfif Discount_Growth_Item_Level eq 1>Item</cfif>

			<cfif Discount_Growth_Group_Level eq 1>&nbsp;Group</cfif>
			<br>Bracket Rate
			<cfif Allow_Growth_Multi_Rate>allowed
			<cfelse>not allowed</cfif>
		</td>
	</tr>


	<!---Formula Pricing--->
	<tr>
		<td>Formula Price</td>
		<cfif Discount_Formula_Pricing IS 1>
			<td>(included)</td>
		<cfelse>
			<td>(not included)</td>
		</cfif>
		<td>N/A</td>
	</tr>

	<!---Bid Rule--->
	<tr>
		<td>Bid Pricing</td>
		<cfif Bid_Rule_Option IS 1>
			<td>(included)</td>
		<cfelse>
			<td>(not included)</td>
		</cfif>
		<td>N/A</td>
	</tr>
</cfif>

	<cfif Generic_Type IS NOT "Distributor Off-Invoice" AND Generic_Type IS NOT "Bid Request" AND Generic_TYpe IS NOT "USDA NOI">
					<!---Discount minimum/maximums--->
					<tr>
						<th>Discount</th>
						<th>Minimum</th>
						<th>Maximum</th>
					</tr>

					<!---Fixed Price--->
					<tr>
						<td valign="top">Fixed Price<div align="right">Pound &nbsp; &nbsp; <Br>Case &nbsp; &nbsp; </div></td>

						<td>&nbsp; <br>
						<cfif len(trim(Min_Fixed_Pound)) GT 0>
						<CF_formatnumber
							number = "#Min_Fixed_Pound#"
							decimals = "4"
							showcurrency = 1
						>
							<Br>
						<cfelse>
						NA<Br>
						</cfif>
						<cfif len(trim(Min_Fixed_Case)) GT 0>
							<CF_formatnumber
							number = "#Min_Fixed_Case#"
							decimals = "4"
							showcurrency = 1
						>
						<cfelse>
						NA
							</cfif>

						</td>
						<td>&nbsp; <br>
						<cfif len(trim(Max_Fixed_Pound)) GT 0>
							<CF_formatnumber
							number = "#Max_Fixed_Pound#"
							decimals = "4"
							showcurrency = 1
						> <Br>
						<cfelse>
						NA<Br>
						</cfif>
						<cfif len(trim(Max_Fixed_Case)) GT 0>
						<CF_formatnumber
							number = "#Max_Fixed_Case#"
							decimals = "4"
							showcurrency = 1
						>
						<cfelse>
						NA
						</cfif>
							</td>
					</tr>


					<!---Rebate--->
					<tr>
						<td valign="top">#Application.RebateLabel#<div align="right"> Pound &nbsp; &nbsp; <Br>Case &nbsp; &nbsp; <Br>Percent &nbsp; &nbsp; </div></td>


						<td>&nbsp; <br>
						<cfif len(trim(Min_Rebate_Pound)) GT 0>
						<CF_formatnumber
							number = "#Min_Rebate_Pound#"
							decimals = "4"
							showcurrency = 1
						> 	<Br>
						<cfelse>
						NA<Br>
						</cfif>
						<cfif len(trim(Min_Rebate_Case)) GT 0>
						<CF_formatnumber
							number = "#Min_Rebate_Case#"
							decimals = "4"
							showcurrency = 1
						>  <br>
						<cfelse>
						NA<Br>
						</cfif>
						<cfif len(trim(Min_Rebate_Percent)) GT 0>
						<CF_formatnumber
							number = "#Min_Rebate_Percent#"
							decimals = "4"
							showcurrency = 1
						>
						<cfelse>
						NA
						</cfif>


						</td>
						<td>&nbsp; <br>
						<cfif len(trim(Max_Rebate_Pound)) GT 0>
						<CF_formatnumber
							number = "#Max_Rebate_Pound#"
							decimals = "4"
							showcurrency = 1
						>  <Br>
						<cfelse>
						NA<Br>
						</cfif>
						<cfif len(trim(Max_Rebate_Case)) GT 0>
						<CF_formatnumber
							number = "#Max_Rebate_Case#"
							decimals = "4"
							showcurrency = 1
						>  <br>
						<cfelse>
						NA<Br>
						</cfif>
						<cfif len(trim(Max_Rebate_Percent)) GT 0>
						<CF_formatnumber
							number = "#Max_Rebate_Percent#"
							decimals = "4"
							showcurrency = 1
						>
						<cfelse>
						NA
						</cfif>
							</td>
					</tr>



					<!---Growth--->
					<tr valign="top">
						<td valign="top">Growth<div align="right"> Pound &nbsp; &nbsp; <Br>Case &nbsp; &nbsp; <Br>Percent &nbsp; &nbsp; </div></td>

						<td>&nbsp; <br>
						<cfif len(trim(Min_Growth_Pound)) GT 0>
						<CF_formatnumber
							number = "#Min_Growth_Pound#"
							decimals = "4"
							showcurrency = 1
						>  <Br>
						<cfelse>
						NA<Br>
						</cfif>
						<cfif len(trim(Min_Growth_Case)) GT 0>
						<CF_formatnumber
							number = "#Min_Growth_Case#"
							decimals = "4"
							showcurrency = 1
						>

							<br>
							<cfelse>
						NA<Br>
						</cfif>
						<cfif len(trim(Min_Growth_Percent)) GT 0>
						<CF_formatnumber
							number = "#Min_Growth_Percent#"
							decimals = "4"
							showcurrency = 1
						>
						<cfelse>
						NA
						</cfif>
						</td>
						<td>&nbsp; <br>

						<cfif len(trim(Max_Growth_Pound)) GT 0>
						<CF_formatnumber
							number = "#Max_Growth_Pound#"
							decimals = "4"
							showcurrency = 1
						>  <Br>
						<cfelse>
						NA<Br>
						</cfif>
						<cfif len(trim(Max_Growth_Case)) GT 0>
						<CF_formatnumber
							number = "#Max_Growth_Case#"
							decimals = "4"
							showcurrency = 1
						>
							<br>
							<cfelse>
						NA<Br>
						</cfif>
						<cfif len(trim(Max_Growth_Percent)) GT 0>
					<CF_formatnumber
							number = "#Max_Growth_Percent#"
							decimals = "4"
							showcurrency = 1
						>
						<cfelse>
						NA
						</cfif>
							</td>
					</tr>

					</tr>

					<!---Formula Pricing--->
					<tr>
						<td valign="top">Formula<div align="right"> Pound &nbsp; &nbsp; <Br>Case &nbsp; &nbsp; </div></td>

						<td>&nbsp; <br>
						<cfif len(trim(Min_Formula_Pound)) GT 0>
						<CF_formatnumber
							number = "#Min_Formula_Pound#"
							decimals = "4"
							showcurrency = 1
						>  <Br>
						<cfelse>
						NA<Br>
						</cfif>
						<cfif len(trim(Min_Formula_Percent)) GT 0>
						<CF_formatnumber
							number = "#Min_Formula_Percent#"
							decimals = "4"
							showcurrency = 1
						>
						<cfelse>
						NA
						</cfif>
						</td>
						<td>&nbsp; <br>
						<cfif len(trim(Max_Formula_Pound)) GT 0>
						<CF_formatnumber
							number = "#Max_Formula_Pound#"
							decimals = "4"
							showcurrency = 1
						>  <Br>
						<cfelse>
						NA<Br>
						</cfif>
						<cfif len(trim(Max_Formula_Percent)) GT 0>
						<CF_formatnumber
							number = "#Max_Formula_Percent#"
							decimals = "4"
							showcurrency = 1
						>
						<cfelse>
						NA
						</cfif>
							 </td>
						</tr>


	<!---Do only if they have the Growth 1 options turned on--->
	<cfif appSettings.getGrowthExpansion1()>

	<tr>
		<th colspan="3">Growth Options</th>
	</tr>
		<!---Allow Multi--->
		<tr>
		<td>Allow bracket rate</td>
		<cfif Allow_Multi IS 1>
			<td>Yes</td>
		<cfelse>
			<td><font color="red">No</font></td>
		</cfif>
		</tr>

	<!---Allow Single--->
	<tr>
		<td>Allow retroactive rate</td>
		<cfif Allow_Single IS 1>
			<td>Yes</td>
		<cfelse>
			<td><font color="red">No</font></td>
		</cfif>
		</tr>

	<!---Allow Stairway--->
	<!---
	<tr>
		<td>Allow stairway</td>
		<cfif Allow_Stairway IS 1>
			<td>Yes</td>
		<cfelse>
			<td><font color="red">No</font></td>
		</cfif>
		</tr>
	--->
	<!---Allow XofY--->
	<!---
	<tr>
		<td>Allow X of Y</td>
		<cfif Allow_XofY IS 1>
			<td>Yes</td>
		<cfelse>
			<td><font color="red">No</font></td>
		</cfif>
		</tr>
	--->
	<!---Allow volume pool seperation--->
	<!---Allow XofY--->
	<tr>
		<td>Allow volume pool separation</td>
		<cfif Allow_Volume_Pool_Seperation IS 1>
			<td>Yes</td>
		<cfelse>
			<td>No</td>
		</cfif>
		</tr>

	</cfif>
	<!---Not bid request or off invoice--->
	<cfelse>

	<!---Discount minimum/maximums--->
	<tr>
		<th>Discount</th>
		<th>Minimum</th>
		<th>Maximum</th>
	</tr>

	<!---Is off invoice or bid request--->
	<cfif  Generic_Type IS "Distributor Off-Invoice">

		<tr>
			<td valign="top">Off Invoice<div align="right"> Pound &nbsp; &nbsp; <Br>Case&nbsp;<br>Percent &nbsp; &nbsp; </div></td>

			<td>&nbsp; <br>
			<cfif len(trim(Min_OffInvoice_Pound)) GT 0>
			<CF_formatnumber
				number = "#Min_OffInvoice_Pound#"
				decimals = "4"
				showcurrency = 1
			>  <Br>
			<cfelse>
						NA<Br>
			</cfif>
			<cfif len(trim(Min_OffInvoice_Case)) GT 0>
			<CF_formatnumber
				number = "#Min_OffInvoice_Case#"
				decimals = "4"
				showcurrency = 1
			>  <Br>
			<cfelse>
						NA<Br>
			</cfif>
			<cfif len(trim(Min_OffInvoice_Percent)) GT 0>
			<CF_formatnumber
				number = "#Min_OffInvoice_Percent#"
				decimals = "4"
				showcurrency = 1
			>
			<cfelse>
						NA
			</cfif>

			</td>
			<td>&nbsp; <br>
			<cfif len(trim(Max_OffInvoice_Pound)) GT 0>
			<CF_formatnumber
				number = "#Max_OffInvoice_Pound#"
				decimals = "4"
				showcurrency = 1
			>  <Br>
			<cfelse>
						NA<Br>
			</cfif>
			<cfif len(trim(Max_OffInvoice_Case)) GT 0>
			<CF_formatnumber
				number = "#Max_OffInvoice_Case#"
				decimals = "4"
				showcurrency = 1
			>  <Br>
			<cfelse>
						NA<Br>
			</cfif>
			<cfif len(trim(Max_OffInvoice_Percent)) GT 0>
			<CF_formatnumber
				number = "#Max_OffInvoice_Percent#"
				decimals = "4"
				showcurrency = 1
			>
			<cfelse>
						NA
			</cfif>
				 </td>
			</tr>
	</cfif>

		<cfif  Generic_Type IS "Bid Request">

		<tr>
			<td valign="top">Proposal (limits allowance)<div align="right"> Pound &nbsp; &nbsp; <Br>Case &nbsp; &nbsp; </div></td>

			<td>&nbsp; <br>
			<cfif len(trim(Min_BidRequest_Pound)) GT 0>
			<CF_formatnumber
				number = "#Min_BidRequest_Pound#"
				decimals = "4"
				showcurrency = 1
			>  <Br>
			<cfelse>
						NA<Br>
			</cfif>
			<cfif len(trim(Min_BidRequest_Case)) GT 0>
			<CF_formatnumber
				number = "#Min_BidRequest_Case#"
				decimals = "4"
				showcurrency = 1
			>
			<cfelse>
						NA
			</cfif>

			</td>
			<td>&nbsp; <br>
			<cfif len(trim(Max_BidRequest_Pound)) GT 0>
			<CF_formatnumber
				number = "#Max_BidRequest_Pound#"
				decimals = "4"
				showcurrency = 1
			>  <Br>
			<cfelse>
						NA<Br>
			</cfif>
			<cfif len(trim(Max_BidRequest_Case)) GT 0>
			<CF_formatnumber
				number = "#Max_BidRequest_Case#"
				decimals = "4"
				showcurrency = 1
			>  <Br>
			<cfelse>
						NA
			</cfif>

				 </td>
			</tr>
	</cfif>

	</cfif>


	<!---Do only if they're using X Material--->
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>

	<cfif appSettings.getUseXMaterial() IS 1>

		<tr>
			<th id="header" colspan="3">Default Product</th>
		</tr>

		<cfif len(trim(Default_Product)) GT 0>

			<cfset useLakebaseForGetDefaultProductName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_items_master")>
<cfif useLakebaseForGetDefaultProductName>
	<cftry>
		<cfset GetDefaultProductName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_items_master", {
				"bsa_foodservice_items_master_id" = "eq.#Default_Product#",
				"select" = "description"
			}), "description"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDefaultProductName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDefaultProductName>
<cfquery name="GetDefaultProductName" datasource="#application.datasource#">
				SELECT Description
				FROM BSA_Foodservice_Items_Master
				WHERE BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = '#Default_Product#'
			</cfquery>
</cfif>

			<tr>
				<td colspan="3">
					<cfif GetDefaultProductName.Recordcount GT 0>#GetDefaultProductName.Description#<cfelse>No default product</cfif>
				</td>
			</tr>

		<cfelse>

			<tr>
				<td colspan="3">
					No default product
				</td>
			</tr>

		</cfif>

	</cfif>
	<!---Claim/Performance Requirements--->

	<cfquery name="GetRequirementsforTemplate" datasource="#application.datasource#">
	SELECT Program_Perf_Req.Requirement_Name
	FROM Program_Perf_Mapping
		INNER JOIN Program_Perf_Req
			ON Program_Perf_Req.Program_Perf_Req_ID = Program_Perf_Mapping.Program_Perf_Req_ID
	WHERE Program_Perf_Mapping.Template_ID = #ID#
	</cfquery>

  <cfif GetRequirementsforTemplate.Recordcount>
    <tr><th colspan="3">Claim/Performance Requirements</th></tr>

  	<cfloop query="GetRequirementsforTemplate">
  		<tr>
  			<td colspan="3">#Requirement_Name#</td>
  		</tr>
  	</cfloop>
  </cfif>

	<!------ show letters ----->
	<cfif appSettings.getlettersavailable()>
	<tr>
		<th>Letters</th>
		<th>Required</th>
		<th>&nbsp;</th>
	</tr>
	<tr>
	<td>#application.returned_customer_setting.operator_label_singular# Letters</td>
	<td><cfif GetAllInfo.operator_letters_required EQ 1><img src="/Images/yes_small.gif"><cfelse><img src="/Images/no_small.gif"></cfif></td>
	</tr>
	<tr>
	<td>#application.returned_customer_setting.distributor_label_singular# Letters</td>
	<td><cfif GetAllInfo.distributor_letters_required EQ 1><img src="/Images/yes_small.gif"><cfelse><img src="/Images/no_small.gif"></cfif></td>
	</tr>
	</cfif>

	<!---Bid request line item --->
	<cfif Generic_Type IS "Bid Request">

	<tr>
		<th colspan="3">Line Item Options</th>
	</tr>

	<cfif GetAllInfo.Bid_Line_Item_Option IS NOT 2>
	<tr>
	<td>Line Item On</td>
	<td><cfif GetAllInfo.Bid_Line_Item_Option_Default IS 1>default</cfif></td>
	</tr>
	</cfif>

	<cfif GetAllInfo.Bid_Line_Item_Option IS NOT 1>
	<tr>
	<td>Line Item Off</td>
	<td><cfif GetAllInfo.Bid_Line_Item_Option_Default IS 2>default</cfif></td>
	</tr>
	</cfif>

	</cfif>

	<!------ show letters ----->
	</table>
</td>
</tr>

	<!---if product category filter is on then display any product category filters--->
	<cfif isDefined("application.returned_customer_setting.product_category_filter") and application.returned_customer_setting.product_category_filter>
	<tr>
		<td colspan="2">
		<table cellpadding="1" cellspacing="0" width="100%" class="longTable">

		<!---get the categories--->
		<cfset productCategory = CreateObject("component", "components.products.Category.ProductCategory") />
		<cfset lCategoryFilters = productCategory.getCategoryFilters(ID) />
		<cfset qGetCategores = productCategory.getCategories(lCategoryFilters) />

		<cfif qGetCategores.RecordCount>
			<tr>
				<th>Filter Product Category</th>
			</tr>
			<cfset maxColCount = 4 />
			<tr>
			<cfloop query="qGetCategores">
					<td>#Category_Name#</td>
					<cfif currentRow mod maxColCount EQ 0>
					  </tr>
					</cfif>
			</cfloop>
			<cfif qGetCategores.RecordCount mod maxColCount neq 0>
			  </tr>
			</cfif>
		</cfif>
		</table>
		</td>
	</tr>
	</cfif>

	<!------ Show selected components for each discoutn type ----->
	<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
	<cfset qGetAllDiscountTypes = templateManager.getAllComponentDiscountTypes(url.id)>
	<cfset discountTypeList = ValueList(qGetAllDiscountTypes.DISCOUNT_TYPE_ID) />
	<cfset qGetAllTemplateDiscountComponents = templateManager.getAllTemplateDiscountComponents(url.id, discountTypeList, 1) />
	<cfset maxCols = 4 />
	<cfset tdWidth = 100/maxCols />
	<tr>
		<td colspan="2">
		<table cellpadding="2" cellspacing="0" width="100%" class="longTable">
		<cfloop query="qGetAllDiscountTypes">
			<cfset Current_Discount_Type_ID = Discount_Type_ID />
			<tr>
			  <th>#Discount_Type_Desc# Components</th>
			</tr>
			<tr>
			<td>
			<cfset useLakebaseForqGetTemplateComponents = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetalltemplatediscountcomponents")>
<cfif useLakebaseForqGetTemplateComponents>
	<cftry>
		<cfset qGetTemplateComponents = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetalltemplatediscountcomponents", {
				"discount_type_id" = "eq.#DISCOUNT_TYPE_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetTemplateComponents = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetTemplateComponents>
<cfquery name="qGetTemplateComponents" dbtype="query">
				SELECT	*
				FROM	qGetAllTemplateDiscountComponents
				WHERE	DISCOUNT_TYPE_ID = #DISCOUNT_TYPE_ID#
			</cfquery>
</cfif>
			<cfif qGetTemplateComponents.recordCount>
				<cfset colsCount = 0 />
				<table cellpadding="1" cellspacing="0" width="100%">
				<tr>
				<cfloop query="qGetTemplateComponents">
				<td width="#tdWidth#%">#Component_Name#</td>
				<cfset colsCount = colsCount + 1 />
				<cfif colsCount GTE maxCols>
					</tr><tr>
					<cfset colsCount = 0 />
				</cfif>
				</cfloop>
				<cfloop from="#colsCount#" to="#maxCols#" index="i" >
					<td width="#tdWidth#%"></td>
				</cfloop>
				</tr>
				</table>
			<cfelse>
				No component found
			</cfif>
			</td>
			</tr>
		</cfloop>
		</table>
		</td>
	</tr>

<!------ show clause ----->				
	<tr>
		<td colspan="2">
			<table cellpadding="1" cellspacing="0" width="100%" class="longTable">
			<tr>
				<th>Clauses</th>
			</tr>			
			<tr>
				<td><cfinclude template="Clause_Template_Display.cfm"></td>
			</tr>
			</table>
		</td>
	</tr>				
<!------ show clause ----->

<!------ show budget ----->
<cfif ViewOnly EQ 0 AND appSettings.getBudgetsFunctionalityOn()>			
	<tr>
		<td colspan="2">
			<table cellpadding="1" cellspacing="0" width="100%" class="longTable">
			<tr>
				<th>Budgets</th>
			</tr>			
			<tr>
				<td><cfinclude template="Budget_Template_Mapping_Summary.cfm"></td>
			</tr>
			</table>
		</td>
	</tr>					
</cfif>
<!------ show budget ----->

	<tr><td align="center" colspan="2">

	<table cellpadding="10" cellspacing="10" border="0">
	<tr><td>
	<form name="ActivateProgram" action="activate.cfm" method="post">
		<input type="hidden" name="ID" value="#ID#">
	</form>

	<form name="GoHome" action="index.cfm" method="post">
		<input type="hidden" name="ID" value="#ID#">
	</form>

	<form name="EditTemplate" action="create_edit.cfm" method="post">
		<input type="hidden" name="ID" value="#ID#">
		<input type="hidden" name="Action" value="Edit">
		<input type="hidden" name="Generic_Type" value="#Generic_Type#">
	</form>
	<CFIF getSPA.Program_Wizard_Index EQ 1 AND ViewOnly IS 0>

	<cfif Active IS 0>
		<CF_button
			button_name		=	""
			button_caption	=	"activate this template"
			button_action	=	"ActivateProgram.submit();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"save and continue"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
	</cfif>
	</td><td >
		<CF_button
			button_name		=	""
			button_caption	=	"edit this template"
			button_action	=	"EditTemplate.submit();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"edit this template"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
			</td><td>
			<CF_button
			button_name		=	""
			button_caption	=	"view template list"
			button_action	=	"GoHome.submit();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"view template list"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>

		<CFELSE>
		<CF_button
			button_name		=	""
			button_caption	=	"close window"
			button_action	=	"window.close();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"close window"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</td></CFIF>
	</tr>
	</table>
	</td></tr>

	</tr>
</TABLE>
<cfinclude template="/common_files/jQuery.cfm">
<script>
  $("table.inputTable td:first-child").addClass("fc21");
  $("table.inputTable td:nth-child(2), table.inputTable td:nth-child(3)").addClass("sc73");
</script>
</body>
</html>
</cfoutput>
