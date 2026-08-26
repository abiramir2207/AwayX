
<cfset checkuom =  0>
<cfquery name="getContractTemplateUOMS" datasource="#application.datasource#">
	SELECT case when RateTypeOption_1 = 1 then 2 else '' end as RateTypeOption_1,
	case when RateTypeOption_2 = 1 then 1 else '' end as RateTypeOption_2,
	case when RateTypeOption_3 = 1 then 3 else '' end as RateTypeOption_3,
	case when RateTypeOption_4 = 1 then 6 else '' end as RateTypeOption_4,
	case when RateTypeOption_5 = 1 then 5 else '' end as RateTypeOption_5,
	case when RateTypeOption_6 = 1 then 7 else '' end as RateTypeOption_6,
	Program_Control_Panel_Options.*
	FROM Program_Control_Panel_Options
	WHERE ProgramControl_Panel_Options_ID = '#templateid#'
</cfquery>

<cfparam name="UOMLIST" default="">

<cfset UOMLIST = "#getContractTemplateUOMS.RateTypeOption_1#,#getContractTemplateUOMS.RateTypeOption_2#,#getContractTemplateUOMS.RateTypeOption_3#,#getContractTemplateUOMS.RateTypeOption_4#,#getContractTemplateUOMS.RateTypeOption_5#,#getContractTemplateUOMS.RateTypeOption_6#">

<CFIF getContractTemplateUOMS.Discount_Fixed_Prices EQ 1>
<cfquery name="getContractFixedUOMS" datasource="#application.datasource#">
	SELECT	Program_Fixed_Price_Product_Data.*
	FROM	Program_Fixed_Price_Product_Data
	where program_id = #program_id#
	and deleted = 0
	and CASE
			WHEN  User_Picked_UOM IN (5, 6,7)THEN User_Picked_UOM
				ELSE unit_of_measure_id
				END NOT IN  (#UOMLIST#)
</cfquery>
<cfif getContractFixedUOMS.recordcount GT 0>
<cfset checkuom = 1 >
</cfif>
</CFIF>

<cfif getContractTemplateUOMS.Generic_Type IS "Distributor Off-Invoice">
<cfquery name="getContractOffinvoiceUOMS" datasource="#application.datasource#">
SELECT	Program_OffInvoice_Product_Data.*
		FROM	Program_OffInvoice_Product_Data
		where program_id = #program_id#
		and deleted = 0
		and UOM NOT IN (#UOMLIST#)
</cfquery>
<cfif getContractOffinvoiceUOMS.recordcount GT 0>
<cfset checkuom = 1 >
</cfif>
</cfif>

<cfif getContractTemplateUOMS.Discount_Rebates EQ 1>
<cfquery name="getContractRebateUOMS" datasource="#application.datasource#">
SELECT 	Program_Rebates_Component_Data.*
		FROM 	Program_Rebates_Component_Data
		inner join Program_Rebates_Product_Data on
		Program_Rebates_Product_Data.Program_Rebates_Product_Data_id =
		Program_Rebates_Component_Data.Program_Rebates_Product_Data_id
		and Program_Rebates_Product_Data.deleted = 0
		where Program_Rebates_Product_Data.program_id = #program_id#
		and Program_Rebates_Component_Data.deleted = 0
		and CASE
			WHEN Program_Rebates_Component_Data.User_Picked_UOM IN (5, 6,7)THEN Program_Rebates_Component_Data.User_Picked_UOM
			ELSE Program_Rebates_Component_Data.unit_of_measure_id
			END NOT IN  (#UOMLIST#)
</cfquery>
<cfif getContractRebateUOMS.recordcount GT 0>
<cfset checkuom = 1 >
</cfif>
</cfif>

<cfif getContractTemplateUOMS.Discount_Growth EQ 1>
<cfquery name="getContractGrowthComponentUOMS" datasource="#application.datasource#">
SELECT 	*
		FROM Program_Growth_Components
		where Program_Growth_Components.program_id = #program_id#
		and Program_Growth_Components.deleted = 0
		and Program_Growth_Components.component_uom NOT IN (#UOMLIST#)
		<cfif appSettings.getDollarGrowth() IS 1>
			AND Program_Growth_Components.component_uom !=4
		</cfif>
</cfquery>
<cfif getContractGrowthComponentUOMS.recordcount GT 0>
<cfset checkuom = 1 >
</cfif>

<cfquery name="getContractGrowthProductsUOMS" datasource="#application.datasource#">
select * from
Program_Growth_Components
inner join Program_Growth_Component_Product_Data
on Program_Growth_Component_Product_Data.Program_Growth_Component_id =
Program_Growth_Components.Program_Growth_Component_id
and Program_Growth_Component_Product_Data.deleted = 0
inner join Program_Growth_Component_Product_Tier_Data on
Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Product_Data_id =
Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_id
and Program_Growth_Component_Product_Tier_Data.deleted = 0
where Program_Growth_Components.program_id = #program_id#
and Program_Growth_Components.deleted = 0
and Program_Growth_Component_Product_Tier_Data.unit_of_measure_id NOT IN (#UOMLIST#)
</cfquery>
<cfif getContractGrowthProductsUOMS.recordcount GT 0>
<cfset checkuom = 1 >
</cfif>
</cfif>


<CFIF getContractTemplateUOMS.Discount_Formula_Pricing EQ 1>
<cfquery name="getContractFormulaPricingUOMS" datasource="#application.datasource#">
SELECT 	Program_Formula_Pricing_Rule_Products.*
		FROM 	Program_Formula_Pricing_Rule_Products
		where program_id = #program_id#
		and deleted = 0
		and unit_of_measure_id NOT IN (#UOMLIST#)
</cfquery>
<cfif getContractFormulaPricingUOMS.recordcount GT 0>
<cfset checkuom = 1 >
</cfif>
</CFIF>

<cfif getContractTemplateUOMS.Generic_Type IS "Bid Request" and getContractTemplateUOMS.Discount_BidRequest EQ 1>
<cfquery name="getContractBidrequestUOMS" datasource="#application.datasource#">
SELECT	Program_Bid_Request_Product.*
		FROM	Program_Bid_Request_Product
		where program_id = #program_id#
		and deleted = 0
		and UOM NOT IN (#UOMLIST#)
</cfquery>
<cfif getContractBidrequestUOMS.recordcount GT 0>
<cfset checkuom = 1 >
</cfif>
</cfif>

<cfif checkuom EQ 0>
<cfset useLakebaseForupdatecontractinfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForupdatecontractinfo>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"contract_main_id" = "eq.#program_id#"
			},
			{
				"check_program_uom" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdatecontractinfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdatecontractinfo>
<cfquery name="updatecontractinfo" datasource="#application.datasource#">
	update contract_main
	set check_program_uom = 0
	where contract_main_id = #program_id#
</cfquery>
</cfif>
</cfif>