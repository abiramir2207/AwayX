<cfmodule template="/customTags/include.cfm" file_to_include="/script/javascript/string_functions.js, /common_files/jQuery.cfm">
<cf_include files="/script/javascript/chosen/chosen.jquery.min.js, /styles/chosen/chosen.css">
<cf_include file_to_include="/styles/jQueryUI_18/smoothness/jquery-ui-1.8.22.custom.css, /script/javascript/ajax_js/jqueryui-1.8.10.min.js, /script/javascript/numeral.min.js, /common_files/datatable.css"/>
<cf_include files="/script/javascript/default.js, /styles/css-loader.css">

<cfset variables.appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<cfset objSettingsService = createobject("component", "mvc.models.SettingsService") />
<cfset QuickPay = createobject("component", "components.Billback.Quick_Pay") />

<cfset stBBLabels = objSettingsService.getBBLabels()>

<cfif isdefined('url.cid')>
	<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">
	<cfset ContractMainID = cryp.value>
<cfelse>
	<cfset ContractMainID = Form.ContractMainID>
</cfif>
<cfset RemainingAccrual = QuickPay.getAccrualAmount(contractmainid)>

<cfset PageTitle = ''>
<cfif len(ContractMainID)>
	<cfquery name="getPrginfo" datasource="#Application.Datasource#"> 
		SELECT PCPO.Billback_Sales_Tax, Contract_Main.*
		FROM Contract_Main
		INNER JOIN Program_Control_Panel_Options PCPO
		ON PCPO.Programcontrol_Panel_Options_ID = Contract_main.ProgramType_ID
		WHERE Contract_Main_ID = #contractmainid#
		AND Contract_Main.Deleted = 0
	</cfquery>
	<cfif variables.appSettings.get_Setting('Quick_Pay_in_Program_Search') EQ 1>
		<cfset PageTitle = #getPrgInfo.Contract_Number#&' '&'Quick Pay'>
	<cfelse>
		<cfset PageTitle = #getPrgInfo.Contract_Number#&' '&'Advance Quick Pay'>
	</cfif>
</cfif>
<cfset ContractNumber = getPrgInfo.Contract_Number>
<cfinclude template="/settings/settings_title.cfm">
<cfinclude template="/get_access_profile.cfm">
<cf_include files="/common_files/noty.cfm">
<!---
variables.appSettings.get_Setting('Quick_Pay_in_Program_Search') == 1 (REGULAR QUICK PAY)
variables.appSettings.get_Setting('Quick_Pay_in_Program_Search') == 2 (ADVANCE QUICK PAY)
	---->
<cfif variables.appSettings.get_Setting('Quick_Pay_in_Program_Search') EQ 1>
	<cfinclude template="quick_pay.cfm">
<cfelse>
	<cfset DDForge = variables.appSettings.get_Setting('DD_In_Forge')>
	<cfinclude template="adv_quick_pay.cfm">
</cfif>
<script>
	function currencyFormat(amount, fmt) {
	fmt = fmt || '($ 0,0.00)';
	return numeral( amount.toString() ).format( fmt );
}
</script>