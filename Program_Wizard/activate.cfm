<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<cfset SPA = CreateObject("component","components.user.settingsPanelAccess").init() />
<cfset getSPA = SPA.getSPAccess()>

<cfif getSPA.Program_Wizard_Index EQ 0>
	<CFLOCATION URL="/Manufacturers/home.cfm" ADDTOKEN="yes">
</cfif>

<cfif isDefined("ID")>

<cfparam name="error_RateType" default="0">
<cfparam name="error_ClaimMech" default="0">
<cfparam name="error_PayOption" default="0">
<cfparam name="error_RateType" default="0">
<cfparam name="error_DiscountType" default="0">

<!---Makes sure that all required fields are accounted for--->
<cfset useLakebaseForGetAllInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForGetAllInfo>
	<cftry>
		<cfset GetAllInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetAllInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetAllInfo>
<cfquery name="GetAllInfo" datasource="#application.datasource#">
	SELECT * FROM Program_Control_Panel_Options 
	WHERE ProgramControl_Panel_Options_ID = #ID#
</cfquery>
</cfif>

<cfparam name="error" default="0">

<cfoutput query="GetAllInfo">

<!---One rate type selected--->
<cfif RateTypeOption_1 IS 0 AND RateTypeOption_2 IS 0 AND RateTypeOption_3 IS 0 AND RateTypeOption_4 IS 0 AND RateTypeOption_5 IS 0 AND RateTypeOption_6 IS 0>
	<cfset error_RateType = 1>
	<cfset error = 1>
</cfif>

<!---Claim mechanic--->
<!------ 
No longer need to check this?
<cfquery name="FindPaymentMapping" datasource="#application.datasource#">
SELECT COUNT(*) AS PaymenTypeCount
FROM Payment_Template_Mapping
WHERE Payment_Template_Mapping.Template_ID = '#ID#'
</cfquery>

<cfif FindPaymentMapping.PaymenTypeCount LT 1 AND Generic_Type IS NOT "Distributor Off-Invoice">
	<cfset error_ClaimMech = 1>
	<cfset error = 1>
</cfif>
 ----->
<!---Payment frequency--->
<cfif PayCycleOption_1 IS 0 AND PayCycleOption_2 IS 0 AND PayCycleOption_3 IS 0 AND PayCycleOption_4 IS 0 AND PayCycleOption_5 IS 0 AND PayCycleOption_6 IS 0 AND PayCycleOption_7 IS 0 AND PayCycleOption_8 IS 0 AND PayCycleOption_9 IS 0 AND PayCycleOption_10 IS 0 AND PayCycleOption_11 IS 0 AND Generic_Type IS NOT "Distributor Off-Invoice">
	<cfset error_PayOption = 1>
	<cfset error = 1>
</cfif>
<!---TSF: Modification Bid Request--->
<!---Discount Types--->
<cfif Discount_Fixed_Prices IS 0 AND Discount_Rebates IS 0 AND Discount_Lump_Sums IS 0 AND Discount_Growth IS 0 AND Discount_Formula_Pricing IS 0 AND Bid_Rule_Option IS 0 AND Generic_Type IS NOT "Distributor Off-Invoice" AND Generic_Type IS NOT "Bid Request">
	<cfset error_DiscountType = 1>
	<cfset error = 1>
</cfif>

</cfoutput>

<cfif error IS 0 OR GetAllInfo.Generic_Type EQ "LSAutoPay">
	<!---Update the record--->
	<cfset useLakebaseForUpdateTemplate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForUpdateTemplate>
	<cftry>
		<cfset application.oLakebase.updateRows("program_control_panel_options",
			{
				"programcontrol_panel_options_id" = "eq.#ID#"
			},
			{
				"active" = "1",
				"updated_by" = "#request.AccessStructure.User_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateTemplate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateTemplate>
<cfquery name="UpdateTemplate" datasource="#application.datasource#">
	UPDATE Program_Control_Panel_Options
	SET 	Active 					= 	1,
			Updated_By				=	'#request.AccessStructure.User_ID#'
	WHERE ProgramControl_Panel_Options_ID = #ID#
	</cfquery>
</cfif>
	
	<cflocation url="/Program_Wizard/index.cfm">

	<cfelse>

	<cflocation url="secondpage.cfm?ID=#ID#&action=Edit&error_DiscountType=#error_DiscountType#&error_PayOption=#error_PayOption#&error_ClaimMech=#error_ClaimMech#&error_RateType=#error_RateType#&Created_Type=#GetAllInfo.Created_Type#&Generic_Type=#GetAllInfo.Generic_Type#">
	
	</cfif>

</cfif>
