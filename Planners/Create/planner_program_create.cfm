<!---------------------------------------------------------------------------------------------------------------------
Template:	/Planners/Create/planner_program_create.cfm
Date:  		06/14/2016
Author:		Tim Ford
Purpose:  	Single Page Planner Program Create
----------------------------------------------------------------------------------------------------------------------->
<cfscript>
    CF_DATE_FORMAT = application.util.query.get_setting("DATE_FORMAT", 0);
    if ( CF_DATE_FORMAT is '' ) {
        CF_DATE_FORMAT = "MM/dd/YYYY";
    }
    else {
        // replace capital 'D' with lower 'd' because CF 2021 returns day of the year for capital 'D'
        CF_DATE_FORMAT = CF_DATE_FORMAT.replace( "D", "d", "ALL" );
    }
    decimal_places_for_EA = application.util.query.get_setting( "Decimal_display_for_EA", 0 );
    decimal_places_for_EA = decimal_places_for_EA is ''
                            ? 2
                            : val( decimal_places_for_EA );
    number_format_for_EA = "(,_." & repeatString( '9', decimal_places_for_EA ) & ")";
</cfscript>

<cfsetting showdebugoutput="yes" />
<cfparam name="url.templateId" 				default="0" />
<cfparam name="form.templateId" 			default="#url.templateId#" />
<cfparam name="form.ProgramType_ID" 		default="#form.templateId#" />
<cfparam name="form.Perf_Start_Date" 		default="" />
<cfparam name="form.Perf_End_Date" 			default="" />
<cfparam name="form.Delivery_Start_Date" 	default="" />
<cfparam name="form.Delivery_End_Date"		default="" />
<cfparam name="form.Marketing_Event"		default="" />
<cfparam name="form.Notes"					default="" />
<cfparam name="form.Budget"					default="" />
<cfparam name="form.lFixedCompIds"			default="" />
<cfparam name="form.lRebateCompIds" 		default="" />
<cfparam name="form.lLumpSumCompIds" 		default="" />
<cfparam name="form.strFixedData"			default="" />
<cfparam name="form.strRebateData" 			default="" />
<cfparam name="form.strLumpSumData" 		default="" />
<cfparam name="form.bSave" 					default="0" />
<cfparam name="form.Contract_Title" 		default="" />
<cfparam name="form.Product_Group_Level_ID"	default="" />
<cfparam name="form.Pricing_Level_ID" 		default="" />
<cfparam name="form.Product_Group_ID" 		default="" />
<cfparam name="url.Product_List" 			default="" />
<cfparam name="form.Product_List" 			default="#url.Product_List#" />
<cfparam name="url.programId" 				default="0" />
<cfparam name="form.programId" 				default="#url.programId#" />
<cfparam name="url.plannerId" 				default="" />
<cfparam name="form.plannerId" 				default="#url.plannerId#" />
<cfparam name="url.customerId" 				default="" />
<cfparam name="form.customerId" 			default="#url.customerId#" />
<cfparam name="url.Product_List_Type" 		default="9" />
<cfparam name="form.Product_List_Type" 		default="#url.Product_List_Type#" />
<cfparam name="url.bInit" 					default="0" />
<cfparam name="form.bFromCompPopUp"			default="0" />
<cfparam name="form.bSaveVolume" 			default="0" />
<cfparam name="form.bHasGroup" 				default="0" />
<cfparam name="form.bIsGroupItems" 			default="0" />
<cfparam name="form.bFormIsValid" 			default="1" />
<cfparam name="form.bFromGroupPopUp" 		default="0" />
<cfparam name="form.GroupLevel_1" 			default="#form.Product_List_Type#" />
<cfparam name="form.approved" 				default="0" />
<cfparam name="url.bCopy" 					default="0" />
<cfparam name="form.bCopy" 					default="#url.bCopy#" />
<cfparam name="url.bRevise" 				default="0" />
<cfparam name="form.bRevise" 				default="#url.bRevise#" />
<cfparam name="form.plTemplatedefaultUOM" 	default="1" />
<cfparam name="form.plTemplateProddefaultUOM" 	default="1" />
<cfparam name="form.plTemplateProgramVolumeDefaultUOM" 	default="1" />
<cfparam name="form.prgTemplateDefaultUOM" 	default="1" />

<cfparam name="form.programIdCopyRevise" 	default="0" />
<cfparam name="form.parentPlannerID" 		default="0" />
<cfparam name="form.bIsInDirect" 			default="0" />
<cfparam name="form.bFromCompPopUpEdit"		default="0" />
<cfparam name="url.removedInactive"			default="0" />
<cfparam name="form.Allow_Retro_Revision" 			default="0">
<cfparam name="form.Allow_Retro_Revision_Span" 		default="0">
<cfparam name="form.isARevsion" 		            default="0">
<cfparam name="form.currency" 		            default="1">
<cfparam name="form.EZButton_On"				default="0" />
<cfparam name="form.EZ_Contract_Id"	            default="0" />
<cfparam name="form.Business_Segment_ID"	    default="0">
<cfparam name="form.Contract_Reference_Number" default="" />
<cfparam name="form.Contract_Reference_Number_2" default="" />


<cfparam name="url.fromProgramSearch"	            default="0" />
<cfparam name="form.CID" default="" />
<cfparam name="form.AltCustomers" default="0" />
<cfparam name="form.bLoadVolumeFromDB" default = "0" />
<cfparam name="form.lsAllocationUOM" 	default="2" />

<!--- Make sure discount component is lists don't have duplicates --->
<cfset form.lFixedCompIds = request.app_general_functions.listRemoveDupes(form.lFixedCompIds, ",") />
<cfset form.lRebateCompIds = request.app_general_functions.listRemoveDupes(form.lRebateCompIds, ",") />
<cfset form.lLumpSumCompIds = request.app_general_functions.listRemoveDupes(form.lLumpSumCompIds, ",") />

<cfif (Find(",",form.programID, 1) AND URL.bcopy EQ 1)>
	<cfset tempPrgIDForm = 0 />
	<cfloop index = "i"  list = "#form.programID#"  delimiters = ",">
		<cfif i GT tempPrgIDForm>
			<cfset tempPrgIDForm = i />
		</cfif>
	</cfloop>
 	<cfset form.programId = tempPrgIDForm />
	<cfset URL.programId = tempPrgIDForm />
	<cfset URL.bcopy = 0 />
	<cfset form.bCopy = 0 />
<cfelse>
	<cfset form.programId = listFirst(form.programId) />
</cfif>


<cf_cryp type="en" key="#request.key#" string="#FORM.programId#">
<cfset FORM.CID = cryp.value>

<cfscript>
    oProgram                = CreateObject("component", "components.programs.program");
    oProduct                = CreateObject("component", "components.products.ProductManager");
    oDistributor            = CreateObject("component", "components.programs.distributors.Distributor");
    oPlannerSettings        = CreateObject("component", "mvc.Models.Planner.PlannerSettingsManager");
    oProgramComponents      = CreateObject("component", "components.programcomponents.programcomponents");
    oTemplateComponents     = CreateObject("component", "components.programs.template.TemplateManager");
    oUom                    = CreateObject("component", "components.programs.rebates.uom");
    oPlannerManager 		= CreateObject("component","mvc.Models.Planner.PlannerManager");
    oPlannerProgram 		= CreateObject("component", "mvc.Models.Planner.PlannerProgramManager");
    labelManager                 = CreateObject("component", "components.settings.Labels.Labels").init();
    oPaymentType            = CreateObject("component", "components.programs.payment_type.paymenttype");
    oPaymentCycleManager	= CreateObject("component", "components.programs.PaymentCycleManager").init();
    oGLAccountManager		= CreateObject("component", "settings.GL_Account.GLAccountManager");
    oVendor					= CreateObject("component", "components.programs.Vendor.vendor");
    oEZProgramManager 		= CreateObject("component", "components.programs.EZButton_programManager");
    oContract 		        = CreateObject("component", "components.programs.rebates.Contract");
    plannerLabels           = labelManager.plannerLabels();
    plannerRebateLabel      = plannerLabels.Rebate_Singular;
</cfscript>

<!--- program selected from calendar would have form.templateID equals to zero --->
<cfif form.templateID eq '0'>
    <cfset useLakebaseForqProgramTemplate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqProgramTemplate>
	<cftry>
		<cfset qProgramTemplate = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#form.programID#",
				"select" = "programtype_id"
			}), "programtype_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqProgramTemplate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqProgramTemplate>
<cfquery name="qProgramTemplate" datasource="#application.datasource#">
        SELECT ProgramType_ID
          FROM Contract_Main
         WHERE contract_main_id = '#form.programID#'
    </cfquery>
</cfif>
    <!--- populate it with appropriate value --->
    <cfset form.templateID = qProgramTemplate.ProgramType_ID>
</cfif>

<!--- pull maximum duration setting (date rules) from program template --->
<cfquery name="qProgramTemplate" datasource="#application.datasource#">
    SELECT Max_Duration, Max_Duration_Length, allow_Reference_2, Lump_Sum_Allocation_Method
      FROM Program_Control_Panel_Options
     WHERE Programcontrol_Panel_Options_ID = <cfqueryparam value="#form.templateId#" cfsqltype="integer">
</cfquery>

<cfset Claim_Mechanics = oTemplateComponents.getTemplateClaimMechanics(form.templateId)>
<cfset defaultClaimMechanics = Claim_Mechanics.ClaimMechDefaultOption>
<!--- gather all scan redemption rebate type --->
<cfset useLakebaseForqScanRedemptions = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_component_name")>
<cfif useLakebaseForqScanRedemptions>
	<cftry>
		<cfset qScanRedemptions = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_rebates_component_name", {
				"rebate_type" = "eq.10",
				"deleted" = "eq.0",
				"active" = "eq.1",
				"select" = "program_rebates_component_name_id"
			}), "program_rebates_component_name_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqScanRedemptions = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqScanRedemptions>
<cfquery name="qScanRedemptions" datasource="#application.datasource#">
    SELECT Program_Rebates_Component_Name_ID
        FROM Program_Rebates_Component_Name
        WHERE Rebate_Type = 10 AND Deleted = 0 AND Active = 1
</cfquery>
</cfif>

<cfset refresh_parent_form = false>

<!--- bring get_UOM() in from udf.cfc --->
<cfset structAppend(url, createObject( "component", "components.udf" ))>
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<!---
Component List variables data structure. Delimited list separated by an _
compNameId	rate	uom	Component_Paid_To	PaymentCycle	lump_sum_apply_to
--->
<cfif form.bFromCompPopUp>
    <!--- Fixed --->
    <cfif len(trim(form.strFixedData))>

        <cfif form.bFromCompPopUpEdit eq 0>
            <cfset form.lFixedCompIds = listAppend(form.lFixedCompIds, ListGetAt(form.strFixedData, 1, "_")) />
        </cfif>

        <cfloop index="idx" list="#form.Product_List#">

            <cfset thisStripGUID = Replace(idx, "-", "_", "ALL") />
            <cfset "form.fixed_comp_#ListGetAt(form.strFixedData, 1, "_")#_#Replace(idx, "-", "_", "ALL")#" 				= ListGetAt(form.strFixedData, 1, "_") />

            <cfif form.bFromCompPopUpEdit eq 0>
                <cfset fxRate = ListGetAt(form.strFixedData, 2, "_") />
                <cfset fxUom = ListGetAt(form.strFixedData, 3, "_") />
            </cfif>

            <cfif form.plTemplateProddefaultUOM eq 1 and form.bFromCompPopUpEdit eq 0><!---  1 = Product UOM, 2 = Planner Template  --->

                <cfif !isDefined( "qProducts" )>
                    <cfset qGetProducts = oPlannerProgram.getproducts(productList=Form.Product_List, productGroupId=form.Product_List_Type)>
                </cfif>
                <!--- Need to get Inventory_UM and net weight ---->
                <cfset useLakebaseForqGetNetWeightInventoryUOM = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetproducts")>
<cfif useLakebaseForqGetNetWeightInventoryUOM>
	<cftry>
		<cfset qGetNetWeightInventoryUOM = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetproducts", {
				"bsa_foodservice_items_master_id" = "eq.#idx#",
				"select" = "inventory_um,net_weight"
			}), "inventory_um,net_weight"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetNetWeightInventoryUOM = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetNetWeightInventoryUOM>
<cfquery name="qGetNetWeightInventoryUOM" dbtype="query">
                    SELECT  Inventory_UM, Net_Weight
                    FROM    qGetProducts
                    WHERE   BSA_Foodservice_Items_Master_ID = '#idx#'
                </cfquery>
</cfif>
                <cfset prodInventoryUM = qGetNetWeightInventoryUOM.Inventory_UM />
                <cfset prodNetWeight = qGetNetWeightInventoryUOM.Net_Weight />

                <cfset prodUseUOM = oPlannerProgram.getDefaultProductUOM(fxUom, form.plTemplateProddefaultUOM, prodInventoryUM) />
                <!--- (form.plTemplatedefaultUOM, form.plTemplateProddefaultUOM, Inventory_UM) --->
                <cfif fxUom eq 1 and prodUseUOM eq 2>
                    <cfset fxRate = fxRate / prodNetWeight />
                    <cfset fxUom  = prodUseUOM />
                <cfelseif fxUom eq 2 and prodUseUOM eq 1>
                    <cfset fxRate = fxRate * prodNetWeight />
                    <cfset fxUom  = prodUseUOM />
                </cfif>
            </cfif>

            <cfscript>
                postfix                                      = "#listGetAt(form.strFixedData, 1, "_")#_#Replace(idx, "-", "_", "ALL")#";
                postfixCompId 								= "#listGetAt(form.strFixedData, 1, "_")#";

                if (form.bFromCompPopUpEdit eq 0){
                    form[ "fixed_rate_" & postfix ]              = fxRate;
                    form[ "fixed_uom_" & postfix ]               = fxUom;
                }

                form[ "fixed_component_paid_to_" & postfix ] = ListGetAt(form.strFixedData, 4, "_");
                form[ "fixed_paymentcycle_" & postfix ]      = ListGetAt(form.strFixedData, 5, "_");
                form[ "fixed_Claim_Mechanics_" & postfix ]   = ListGetAt(form.strFixedData, 7, "_");
                form[ "fixed_GL_Account_ID_" & postfix ]     = ListGetAt(form.strFixedData, 8, "_");
                form[ "fixed_Vendor_Master_ID_" & postfix ]  = ListGetAt(form.strFixedData, 9, "_");
                form[ "fixed_Vendor_Selection_" & postfix ]  = ListGetAt(form.strFixedData, 10, "_");
                form[ "fixed_Payee_Selection_" & postfix ]   = ListGetAt(form.strFixedData, 11, "_");

                form[ "fixed_component_paid_to_" & postfixCompId ] = ListGetAt(form.strFixedData, 4, "_");
                form[ "fixed_paymentcycle_" & postfixCompId ]      = ListGetAt(form.strFixedData, 5, "_");
                form[ "fixed_Claim_Mechanics_" & postfixCompId ]   = ListGetAt(form.strFixedData, 7, "_");
                form[ "fixed_GL_Account_ID_" & postfixCompId ]     = ListGetAt(form.strFixedData, 8, "_");
                form[ "fixed_Vendor_Master_ID_" & postfixCompId ]  = ListGetAt(form.strFixedData, 9, "_");
                form[ "fixed_Vendor_Selection_" & postfixCompId ]  = ListGetAt(form.strFixedData, 10, "_");
                form[ "fixed_Payee_Selection_" & postfixCompId ]   = ListGetAt(form.strFixedData, 11, "_");

            </cfscript>

            <cfif ListLen(form.lFixedCompIds) eq 1><!--- when adding first FP comp --->

                <cfset thisFixedSumRate = convertDiscountToUOM(1, fxUom, fxRate, form["prodUom__" & thisStripGUID], form["price_" & thisStripGUID], form["netWeight_" & thisStripGUID], form[ "bUnits_" & thisStripGUID ], form["Sleeves_per_case_" & thisStripGUID]) />

                <cfif thisFixedSumRate eq "">
                    <cfset thisFixedSumRate = 0 />
                </cfif>

                <cfset thisFixedSumRate = ltrim(rtrim(val(thisFixedSumRate))) />

                <cfset "form.discountSum_#thisStripGUID#" = form[ "discountSum_" & thisStripGUID] + thisFixedSumRate />

            </cfif>

        </cfloop>

        <cfset form.strFixedData 	= "" />
        <cfset form.bFromCompPopUp 	=  0/>
        <cfset form.bFromCompPopUpEdit = 0 />

    <!--- Rebate --->
    <cfelseif len(trim(form.strRebateData))>

        <cfif form.bFromCompPopUpEdit eq 0>
            <cfset form.lRebateCompIds = listAppend(form.lRebateCompIds, ListGetAt(form.strRebateData, 1, "_")) />
        </cfif>

        <cfloop index="idx" list="#form.Product_List#">

            <cfset thisStripGUID = Replace(idx, "-", "_", "ALL") />
            <cfset "form.rebate_comp_#ListGetAt(form.strRebateData, 1, "_")#_#Replace(idx, "-", "_", "ALL")#" 				= ListGetAt(form.strRebateData, 1, "_") />

            <cfset rebRate = 	ListGetAt(form.strRebateData, 2, "_") />
            <cfset rebUom =		ListGetAt(form.strRebateData, 3, "_") />

            <cfif form.plTemplateProddefaultUOM eq 1 and form.bFromCompPopUpEdit eq 0><!---  1 = Product UOM, 2 = Planner Template  --->

                <cfif !isDefined("qProducts")>
                    <cfset qGetProducts = oPlannerProgram.getproducts(productList=Form.Product_List, productGroupId=form.Product_List_Type)>
                </cfif>
                <!--- Need to get Inventory_UM and net weight ---->
                <cfquery name="qGetNetWeightInventoryUOM" dbtype="query">
                    SELECT  Inventory_UM, Net_Weight
                    FROM    qGetProducts
                    WHERE   BSA_Foodservice_Items_Master_ID = '#idx#'
                </cfquery>
                <cfset prodInventoryUM = qGetNetWeightInventoryUOM.Inventory_UM />
                <cfset prodNetWeight = qGetNetWeightInventoryUOM.Net_Weight />

                <cfset prodUseUOM = oPlannerProgram.getDefaultProductUOM(rebUom, form.plTemplateProddefaultUOM, prodInventoryUM) />
                <cfif rebUom eq 1 and prodUseUOM eq 2>
                    <cfset rebRate = rebRate / prodNetWeight />
                    <cfset rebUom  = prodUseUOM />
                <cfelseif rebUom eq 2 and prodUseUOM eq 1>
                    <cfset rebRate = rebRate * prodNetWeight />
                    <cfset rebUom  = prodUseUOM />
                </cfif>
            </cfif>

            <cfscript>
                postfix = "#ListGetAt(form.strRebateData, 1, "_")#_#Replace(idx, "-", "_", "ALL")#";
                postfixCompId = "#listGetAt(form.strRebateData, 1, "_")#";

                if (form.bFromCompPopUpEdit eq 0){
                    form[ "rebate_rate_" & postfix ] 				= rebRate;
                    form[ "rebate_uom_" & postfix ] 				= rebUom;
                    form[ "rebate_scan_" & postfix ] 				= ListGetAt(form.strRebateData, 12, "_", true);
                }
                form[ "rebate_component_paid_to_" & postfix ]	= ListGetAt(form.strRebateData, 4, "_");
                form[ "rebate_paymentcycle_" & postfix ] 		= ListGetAt(form.strRebateData, 5, "_");
                form[ "rebate_Claim_Mechanics_" & postfix ] 	= ListGetAt(form.strRebateData, 7, "_");
                form[ "rebate_GL_Account_ID_" & postfix ] 		= ListGetAt(form.strRebateData, 8, "_");
                form[ "rebate_Vendor_Master_ID_" & postfix ] 	= ListGetAt(form.strRebateData, 9, "_");
                form[ "rebate_Vendor_Selection_" & postfix ] 	= ListGetAt(form.strRebateData, 10, "_");
                form[ "rebate_Payee_Selection_" & postfix ] 	= ListGetAt(form.strRebateData, 11, "_");

                form[ "rebate_component_paid_to_" & postfixCompId ]	= ListGetAt(form.strRebateData, 4, "_");
                form[ "rebate_paymentcycle_" & postfixCompId ] 		= ListGetAt(form.strRebateData, 5, "_");
                form[ "rebate_Claim_Mechanics_" & postfixCompId ] 	= ListGetAt(form.strRebateData, 7, "_");
                form[ "rebate_GL_Account_ID_" & postfixCompId ] 		= ListGetAt(form.strRebateData, 8, "_");
                form[ "rebate_Vendor_Master_ID_" & postfixCompId ] 	= ListGetAt(form.strRebateData, 9, "_");
                form[ "rebate_Vendor_Selection_" & postfixCompId ] 	= ListGetAt(form.strRebateData, 10, "_");
                form[ "rebate_Payee_Selection_" & postfixCompId ] 	= ListGetAt(form.strRebateData, 11, "_");
                form[ "rebate_scan_" & postfixCompId ] 	= ListGetAt(form.strRebateData, 12, "_", true);
            </cfscript>

            <cfset thisRebateSumRate = convertDiscountToUOM(2, rebUom, rebRate, form["prodUom__" & thisStripGUID], form["price_" & thisStripGUID], form["netWeight_" & thisStripGUID], form[ "bUnits_" & thisStripGUID ], form["Sleeves_per_case_" & thisStripGUID]) />

            <cfif thisRebateSumRate eq "">
                <cfset thisRebateSumRate = 0 />
            </cfif>

            <cfset thisRebateSumRate = ltrim(rtrim(val(thisRebateSumRate))) />

            <cfset "form.discountSum_#thisStripGUID#" = form[ "discountSum_" & thisStripGUID] + thisRebateSumRate />

        </cfloop>

        <cfset form.strRebateData 	= "" />
        <cfset form.bFromCompPopUp 	=  0/>
        <cfset form.bFromCompPopUpEdit = 0 />

    <!--- Lump Sum --->
    <cfelseif len(trim(form.strLumpSumData))>

        <cfif form.bFromCompPopUpEdit eq 0>
            <cfset form.lLumpSumCompIds = listAppend(form.lLumpSumCompIds, ListGetAt(form.strLumpSumData, 1, "_")) />
        </cfif>
        <cfset lsApplyTo = ListGetAt(form.strLumpSumData, 6, "_") />

        <cfif lsApplyTo eq "1">
            <cfset lsRateVal = ListGetAt(form.strLumpSumData, 2, "_") />
        <cfelse>
            <cfset lsRateVal = ListGetAt(form.strLumpSumData, 2, "_") / listLen(form.Product_List) />
        </cfif>

        <!---total up all volumes--->
        <cfscript>
            // total up all volumes
            volume_total = 0;
            qGetProducts = oPlannerProgram.getproducts( productList=Form.Product_List, productGroupId=form.Product_List_Type );
		</cfscript>

        <cfloop collection="#form#" item="element">
            <cfif element.findNoCase( "vol." ) eq 1>
                <cfset product_sql_guid = listLast( element, '.' )>
                <cfset product_volume = replace(form[ element ], ',', '', 'all') * getVolumeFactor( product_sql_guid )>
                <cfset volume_total += product_volume>
            </cfif>
        </cfloop>

			<cfscript>
	            // calculate lump sum amount for one volume ( product )
	            lump_sum_per_volume    = ( volume_total eq 0 ? 0 : lsRateVal / volume_total );
	            lump_sum_running_total = 0;
	            last_product_sql_guid  = listLast( form.Product_List );
			</cfscript>

			 <cfloop index="product_sql_guid" list="#form.Product_List#">
				<cfscript>
                // define product guid cf friendly variable
                product_cf_guid = replace( product_sql_guid, '-', '_', "all" );
                postfix         = "#listFirst( form.strLumpSumData, "_" )#_#product_cf_guid#";
                postfixCompId   = listFirst( form.strLumpSumData, "_" );

                form[ "lump_sum_comp_" & postfix ] = listFirst( form.strLumpSumData, "_" );

                if ( form.bFromCompPopUpEdit eq 0 ) {
                    form[ "lump_sum_rate_" & postfix ] = lsRateVal;
                    form[ "lump_sum_uom_" & postfix ]  = ListGetAt(form.strLumpSumData, 3, "_");

                    if ( qProgramTemplate.Lump_Sum_Allocation_Method is "component_product" ) {
                        product_volume = form[ "vol." & product_sql_guid ] * getVolumeFactor( product_sql_guid );
                        // if last product get the remaining balance, otherwise calculate based on product volume
                        product_amount = ( product_sql_guid eq last_product_sql_guid
                                                ? lsRateVal - lump_sum_running_total
                                                : numberFormat( lump_sum_per_volume * product_volume, ".99" ) );
                        form[ "lump_sum_rate_" & postfix ] = product_amount;
                        lump_sum_running_total =+ product_amount;
                    }
                }

                form[ "lump_sum_component_paid_to_" & postfix ]	= ListGetAt(form.strLumpSumData, 4, "_");
                form[ "lump_sum_paymentcycle_" & postfix ] 		= ListGetAt(form.strLumpSumData, 5, "_");
                form[ "lump_sum_apply_to_" & postfix ] 			= ListGetAt(form.strLumpSumData, 6, "_");
                form[ "lump_sum_Claim_Mechanics_" & postfix ] 	= ListGetAt(form.strLumpSumData, 7, "_");
                form[ "lump_sum_GL_Account_ID_" & postfix ] 	= ListGetAt(form.strLumpSumData, 8, "_");
                form[ "lump_sum_Vendor_Master_ID_" & postfix ] 	= ListGetAt(form.strLumpSumData, 9, "_");
                form[ "lump_sum_Vendor_Selection_" & postfix ] 	= ListGetAt(form.strLumpSumData, 10, "_");
                form[ "lump_sum_Payee_Selection_" & postfix ] 	= ListGetAt(form.strLumpSumData, 11, "_");

                form[ "lump_sum_component_paid_to_" & postfixCompId ]	= ListGetAt(form.strLumpSumData, 4, "_");
                form[ "lump_sum_paymentcycle_" & postfixCompId ] 		= ListGetAt(form.strLumpSumData, 5, "_");
                form[ "lump_sum_apply_to_" & postfixCompId ] 			= ListGetAt(form.strLumpSumData, 6, "_");
                form[ "lump_sum_Claim_Mechanics_" & postfixCompId ] 	= ListGetAt(form.strLumpSumData, 7, "_");
                form[ "lump_sum_GL_Account_ID_" & postfixCompId ] 	    = ListGetAt(form.strLumpSumData, 8, "_");
                form[ "lump_sum_Vendor_Master_ID_" & postfixCompId ] 	= ListGetAt(form.strLumpSumData, 9, "_");
                form[ "lump_sum_Vendor_Selection_" & postfixCompId ] 	= ListGetAt(form.strLumpSumData, 10, "_");
                form[ "lump_sum_Payee_Selection_" & postfixCompId ] 	= ListGetAt(form.strLumpSumData, 11, "_");
			</cfscript>
        </cfloop>
			<cfscript>
            form.strLumpSumData 	= "";
            form.bFromCompPopUp 	= 0;
            form.bFromCompPopUpEdit = 0;

            form[ "lump_sum_component_amount_" & postfixCompId ] = lsRateVal;
        </cfscript>
    </cfif>

</cfif> <!--- form.bFromCompPopUp --->

<!--- save program data --->
<cfif form.bSave eq 1>

    <cfset bNewProgram = form.programId />
    <cfset form.lFixedCompIds = request.app_general_functions.listRemoveDupes(form.lFixedCompIds, ",") />
    <cfset form.lRebateCompIds = request.app_general_functions.listRemoveDupes(form.lRebateCompIds, ",") />
    <cfset form.lLumpSumCompIds = request.app_general_functions.listRemoveDupes(form.lLumpSumCompIds, ",") />

    <!--- 	WR D106960: Planner Lump Sum not able to revise
            This is to handle for an issue with gridviewscroll. If items scroll beyond the size of the page then the lump_sum_component_amount value entered
            gets put in a form variable with a suffix of freezeitem. To handle for this we need to check if this form variable exists. If it does then we need
            to set the lump_sum_component_amount to the value that's in the freezeitem form variable
    --->
    <cfloop list="#form.lLumpSumCompIds#" index="idx">
        <cfif isDefined("form.lump_sum_component_amount_#idx#_freezeitem")>
            <cfset "form.lump_sum_component_amount_#idx#" = form[ "lump_sum_component_amount_" & idx & "_freezeitem" ] />
        </cfif>
    </cfloop>

    <cfset form.programId = oPlannerProgram.saveProgramPlannerData(form) />

    <!--- RETAIL-359  Copy from program menu changes: Remove inactive items --->
    <cfif form.bCopy eq 1>

        <cfset useLakebaseForqCheckInactivePrograms = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_copy_removed_product")>
<cfif useLakebaseForqCheckInactivePrograms>
	<cftry>
		<cfset qCheckInactivePrograms = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_copy_removed_product", {
				"contract_main_id" = "eq.#form.programId#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckInactivePrograms = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckInactivePrograms>
<cfquery name="qCheckInactivePrograms" datasource="#application.datasource#">
            SELECT	*
            FROM 	Program_Copy_Removed_Product
            WHERE	Contract_Main_ID = '#form.programId#'
        </cfquery>
</cfif>

        <cfif qCheckInactivePrograms.RecordCount>

            <cflocation url="/Planners/Create/planner_program_create.cfm?programId=#form.programId#&plannerID=#form.plannerId#&customerID=#form.customerId#&templateId=#form.templateId#&bInit=1&removedInactive=1&bLock=1" />

        </cfif>

        <!--- flag to lock the newly copied program (performed in layout_planner_program.cfm ) --->
        <cfset url.bLock = 1>
    </cfif>

    <cfset bSaveFromNewProgramDisabledFieldsNoIndirectVol = 1 />
    <cfif form.bIsInDirect eq 0 or form.bRevise eq 1 or form.bCopy eq 1 or bNewProgram neq 0>
        <cfset bSaveFromNewProgramDisabledFieldsNoIndirectVol = 0 />
    </cfif>

    <cfset form.bSave 		= 0 />
    <cfset form.bCopy		= 0 />
    <cfset form.bRevise		= 0 />
    <cfset form.programIdCopyRevise = 0 />

    <cfif not bSaveFromNewProgramDisabledFieldsNoIndirectVol>

        <cfset qGetProductsOnSave 		= oPlannerProgram.getproducts(productList=Form.Product_List, productGroupId=form.Product_List_Type) />
        <cfset qGetPlannerVolumeData	= oPlannerProgram.getProgramPlannerVolumeData(form.programId) />

        <cfloop index="idx" list="#form.Product_List#">

            <cfset useLakebaseForqGetVol = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetplannervolumedata")>
<cfif useLakebaseForqGetVol>
	<cftry>
		<cfset qGetVol = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetplannervolumedata", {
				"bsa_foodservice_items_master_id" = "eq.#idx#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetVol = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetVol>
<cfquery name="qGetVol" dbtype="query">
                SELECT	*
                FROM	qGetPlannerVolumeData
                WHERE	BSA_Foodservice_Items_Master_ID = '#idx#'
            </cfquery>
</cfif>

            <!--- Need to get Inventory_UM and net weight ---->
            <cfquery name="qGetNetWeightInventoryUOM" dbtype="query">
                SELECT  Inventory_UM, Net_Weight, Case_Count, Sleeves_per_case
                FROM    qGetProductsOnSave
                WHERE   BSA_Foodservice_Items_Master_ID = '#idx#'
            </cfquery>
            <cfset prodUOM = oPlannerProgram.getDefaultProductUOM(form.plTemplatedefaultUOM, form.plTemplateProddefaultUOM, qGetNetWeightInventoryUOM.Inventory_UM) />

            <cfif prodUOM eq 2>
                <cfif qGetVol.Volume_LB eq "">
                    <cfset volVal = 0 />
                <cfelse>
                    <cfset volVal = qGetVol.Volume_LB />
                </cfif>
            <cfelse>
                <cfif qGetVol.Volume_CS eq "">
                    <cfset volVal = 0 />
                <cfelse>
                    <cfset volVal = qGetVol.Volume_CS />
                </cfif>
            </cfif>

            <!--- If the “Program Volume Default UOM:” is set to “Program Template” then we need to use the default UOM from program template. Need to convert volume. --->
            <cfif form.plTemplateProgramVolumeDefaultUOM eq 2>
                <cfset volVal = oPlannerProgram.convertVolume(volVal, prodUOM, form.prgTemplateDefaultUOM, qGetNetWeightInventoryUOM.Net_Weight, qGetNetWeightInventoryUOM.Case_Count, qGetNetWeightInventoryUOM.Sleeves_per_case)  />
            </cfif>
            <cfset form["vol." & idx] = volVal />

            <!---Set the discount sums to 0 so we don't double up when summing below--->
            <cfset thisStripGUID = Replace(idx, "-", "_", "ALL") />
            <cfset "form.discountSum_#thisStripGUID#" = 0 />

        </cfloop>

    </cfif>


    <!---- Save Budget Selection ---->
      <!--- contains fn save_budgets_all_versions() --->
      <cfinclude template="/common_files/contracts/budget_save_functions.cfm" />
      <cfset vars.arBudgetList = ArrayNew(1) />

    <cfif form.Budget neq "">
        <cfquery name="qGetBudget" datasource="#application.datasource#">
            SELECT  Budget_Class_ID
            FROM    Budget
            WHERE   Budget_ID = <cfqueryparam value="#form.Budget#" cfsqltype="cf_sql_integer">
        </cfquery>
      <cfset vars.stBudgetSelection = StructNew() />
      <cfset vars.stBudgetSelection.BudgetClassID = qGetBudget.Budget_Class_ID />
      <cfset vars.stBudgetSelection.BudgetID = form.Budget />
      <cfset ArrayAppend(vars.arBudgetList, vars.stBudgetSelection) />
    </cfif>

      <cfset save_budgets_all_versions(form.programId, vars.arBudgetList) />

    <cfset refresh_parent_form = true>
</cfif> <!--- form.bSave --->

<cfscript>
    qGetData 				= oPlannerProgram.getProgramPlannerData(form.programId);

    if(form.programId neq 0 and form.plannerId eq ""){
        form.plannerId = qGetData.Planner_ID;
    }

    if(form.programId neq 0 and form.templateId eq 0){
        form.templateId = qGetData.ProgramType_ID;
    }

    qGetPlannerData 		= oPlannerManager.getPlanner( plannerID=form.plannerId);

    if(form.plannerId neq 0 and form.customerId eq ""){
        form.customerId = qGetPlannerData.BSA_FoodService_Customers_ID;
    }

    if (isNumeric(qGetPlannerData.Parent_Planner_ID) and qGetPlannerData.Parent_Planner_ID neq 0){
        strPlannerType = "inDirect";
        form.parentPlannerID = qGetPlannerData.Parent_Planner_ID;
        local.directPlannerId = form.parentPlannerID;
        form.bIsInDirect = 1;
    }
    else{
        strPlannerType = "direct";
        local.directPlannerId = form.plannerId;
    }

    qGetProgramUserSettings = oProgram.getProgramUserSettings();
    qGetProducts            = oPlannerProgram.getproducts(productList=Form.Product_List, productGroupId=form.Product_List_Type);
    qGetPlannerPerfTypes    = oPlannerProgram.getPlannerProgramPerfTypeInfo(templateId=qGetPlannerData.Planner_Template_ID, plannerType=strPlannerType, programPerfId=qGetData.Planner_Perf_Type_ID, programTemplateId=form.templateID);
    qGetDistributor         = oDistributor.getDistributor(form.customerId);
    qGetTemplates           = oTemplateComponents.getAllDiscountTypes(form.templateId);
    qGetPlannerProfileData 	= oPlannerManager.getPlannerProfile( plannerID=form.plannerId );
    qPlannerProfileProducts = oPlannerManager.getSavedPlannerProfileProductData(form.plannerId);
    oGetTemplateData        = oTemplateComponents.get(form.templateId);
    qGetUnitPriceData 		= oPlannerProgram.getUnitPrice(form.programId);

    form.plTemplatedefaultUOM	= qGetPlannerData.UOM_Default;
    form.plTemplateProddefaultUOM	= qGetPlannerData.Program_Default_UOM;
    form.plTemplateProgramVolumeDefaultUOM	= qGetPlannerData.Program_Volume_Default_UOM;
    form.lsAllocationUOM = form.plTemplatedefaultUOM;

    if(form.programId neq 0){
        qGetProgramData			= oProgram.getProgramInfo(form.programId);
        form.approved			= qGetProgramData.Approved;

         // if form.plTemplateProgramVolumeDefaultUOM = 2 then we need to use the default UOM from program template for volume
        if(form.plTemplateProgramVolumeDefaultUOM eq 2){
            // get the program template default UOM
            form.prgTemplateDefaultUOM = oContract.getDefaultUom(form.programId);
            form.lsAllocationUOM = form.prgTemplateDefaultUOM;
        }

    }

    if(val(form.lsAllocationUOM) eq 0){
        form.lsAllocationUOM = 2;
    }
    else if (form.lsAllocationUOM neq 1 and form.lsAllocationUOM neq 2 ){
        form.lsAllocationUOM = 1;
    }

    gGetProdGroupAttr		= oPlannerSettings.getProductGroupTypeData();

    //add ez button data
    form.EZButton_On		= qGetData.EZButton_On;
    form.EZ_Contract_ID		= qGetData.EZ_Contract_Id;
</cfscript>



<cfquery name="gGetExpMargin" dbtype="query">
    SELECT DISTINCT Planner_Expected_Margin
    FROM qGetPlannerProfileData
</cfquery>


<cfif form.bCopy eq 1>
    <CFINCLUDE TEMPLATE="/Common_Files/contracts/contract_number_generator.cfm">
    <cfset form.Contract_Number = generator_contract_number />
<!--- if we don't have a program id then the program has not been created yet so we need to generate one --->
<cfelseif form.programId eq 0 and form.bRevise eq 0>
    <CFINCLUDE TEMPLATE="/Common_Files/contracts/contract_number_generator.cfm">
    <cfset form.Contract_Number = generator_contract_number />
<cfelse>
    <cfset qGetData = oPlannerProgram.getProgramPlannerData(form.programId) />
    <cfset form.Contract_Number = qGetData.Contract_Number />
</cfif>

<cf_layout_planner_program jQueryUI="1.11.4" page_title="Planner Program">

<!--- Check if the template allows fixed --->
<cfset useLakebaseForqHasFixedComp = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgettemplates")>
<cfif useLakebaseForqHasFixedComp>
	<cftry>
		<cfset qHasFixedComp = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgettemplates", {
				"discount_type_id" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqHasFixedComp = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqHasFixedComp>
<cfquery name="qHasFixedComp" dbtype="query">
    SELECT * FROM qGetTemplates WHERE Discount_Type_ID = 1
</cfquery>
</cfif>
<!--- Check if the template allows rebate --->
<cfset useLakebaseForqHasRebateComp = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgettemplates")>
<cfif useLakebaseForqHasRebateComp>
	<cftry>
		<cfset qHasRebateComp = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgettemplates", {
				"discount_type_id" = "eq.2"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqHasRebateComp = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqHasRebateComp>
<cfquery name="qHasRebateComp" dbtype="query">
    SELECT * FROM qGetTemplates WHERE Discount_Type_ID = 2
</cfquery>
</cfif>
<!--- Check if the template allows lump sum --->
<cfset useLakebaseForqHasLumpComp = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgettemplates")>
<cfif useLakebaseForqHasLumpComp>
	<cftry>
		<cfset qHasLumpComp = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgettemplates", {
				"discount_type_id" = "eq.3"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqHasLumpComp = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqHasLumpComp>
<cfquery name="qHasLumpComp" dbtype="query">
    SELECT * FROM qGetTemplates WHERE Discount_Type_ID = 3
</cfquery>
</cfif>

<cfif form.bSaveVolume>
    <cfscript>
        oPlannerProgram.saveProgramPlannerVolumeData(form);
        form.bSaveVolume = 0;
    </cfscript>
</cfif>

<cfif form.bFromGroupPopUp eq 1>
    <cfset form.Product_List_Type = form.GroupLevel_1 />
    <cfset form.bFromGroupPopUp = 0 />
</cfif>

<!--- Run this code when planner program created gets called from calendar or volume plan --->
<cfif url.bInit eq 1>

    <cfscript>
        qGetProdData          = oPlannerProgram.getProgramPlannerProductData(form.programId);
        qGetFixedData         = oPlannerProgram.getProgramPlannerFixedData(form.programId);
        qGetRebateData        = oPlannerProgram.getProgramPlannerRebateData(form.programId);
        qGetLumpSumData       = oPlannerProgram.getProgramPlannerLumpSumData(form.programId);
        gGetProductGroupType  = oPlannerProgram.getProgramProductGroupType(form.programId);

        form.plannerId 				= qGetData.Planner_Id;
        form.Contract_Title 		= qGetData.Contract_Title;
        form.Perf_Start_Date 		= dateformat(qGetData.Performance_Start_Date, CF_DATE_FORMAT);
        form.Perf_End_Date 			= dateformat(qGetData.Performance_End_Date, CF_DATE_FORMAT);
        form.Notes 					= qGetData.Notes;
        form.Planner_Perf_Types_ID	= qGetData.Planner_Perf_Type_ID;
        form.isARevsion         	= qGetData.Is_A_Revision;
        form.currency               = qGetData.Currency;
		form.Contract_Reference_Number =  qGetData.Contract_Reference_Number;
		form.Contract_Reference_Number_2 =  qGetData.Contract_Reference_Number_2;

        //set product group level fields only if whe get a record set
        if(gGetProductGroupType.RecordCount){
            form.Product_List_Type = gGetProductGroupType.Product_Group_Level_ID;
            form.GroupLevel_1      = gGetProductGroupType.Product_Group_Level_ID;
        }
        else{
            form.Product_List_Type = 9;
            form.GroupLevel_1      = 0;
        }
        form.Delivery_Start_Date = dateformat(qGetData.Contract_Start_Date, CF_DATE_FORMAT);
        form.Delivery_End_Date   = dateformat(qGetData.Contract_End_Date, CF_DATE_FORMAT);
		form.AltCustomers = qGetData.Alternate_Customer_ON;
    </cfscript>

    <!--- loop over the data and map form fields --->

    <!--- fixed mappings start--->
    <cfset useLakebaseForqGetFixedCompId = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetfixeddata")>
<cfif useLakebaseForqGetFixedCompId>
	<cftry>
		<cfset qGetFixedCompId = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetfixeddata", {
				"select" = "compnameid,uom"
			}), "compnameid,uom"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetFixedCompId = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetFixedCompId>
<cfquery name="qGetFixedCompId" dbtype="query">
        SELECT 	DISTINCT compNameId, uom
        FROM	qGetFixedData
    </cfquery>
</cfif>

    <cfset form.lFixedCompIds = ValueList(qGetFixedCompId.compNameId) />

    <cfloop query="qGetFixedData">

            <cfscript>
                postfix = "#qGetFixedData.compNameId#_#Replace(qGetFixedData.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#";
                postfixCompId = "#qGetFixedData.compNameId#";
                form[ "fixed_comp_" & postfix ]              =  compNameId;
                form[ "fixed_uom_" & postfix ]               = uom;
                form[ "fixed_component_paid_to_" & postfix ] = Component_Paid_To;
                form[ "fixed_paymentcycle_" & postfix ]      = PaymentCycle;
                form[ "fixed_rate_" & postfix ]              = Rate;
                form[ "fixed_Claim_Mechanics_" & postfix ]   = Claim_Mechanics;
                form[ "fixed_GL_Account_ID_" & postfix ]     = GL_Account_ID;
                form[ "fixed_Vendor_Master_ID_" & postfix ]  = Vendor_Master_ID;
                form[ "fixed_Vendor_Selection_" & postfix ]  = Vendor_Selection;
                form[ "fixed_Payee_Selection_" & postfix ]   = Payee_Selection;

                form[ "fixed_component_paid_to_" & postfixCompId ] = Component_Paid_To;
                form[ "fixed_paymentcycle_" & postfixCompId ]      = PaymentCycle;
                form[ "fixed_Claim_Mechanics_" & postfixCompId ]   = Claim_Mechanics;
                form[ "fixed_GL_Account_ID_" & postfixCompId ]     = GL_Account_ID;
                form[ "fixed_Vendor_Master_ID_" & postfixCompId ]  = Vendor_Master_ID;
                form[ "fixed_Vendor_Selection_" & postfixCompId ]  = Vendor_Selection;
                form[ "fixed_Payee_Selection_" & postfixCompId ]   = Payee_Selection;
            </cfscript>

    </cfloop>
    <!--- fixed mappings end--->

    <!--- rebate mappings start--->
    <cfset useLakebaseForqGetRebateCompId = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetrebatedata")>
<cfif useLakebaseForqGetRebateCompId>
	<cftry>
		<cfset qGetRebateCompId = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetrebatedata", {
				"select" = "compnameid,uom"
			}), "compnameid,uom"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetRebateCompId = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetRebateCompId>
<cfquery name="qGetRebateCompId" dbtype="query">
        SELECT 	DISTINCT compNameId, uom
        FROM	qGetRebateData
    </cfquery>
</cfif>

    <cfset form.lRebateCompIds = ValueList(qGetRebateCompId.compNameId) />

    <cfloop query="qGetRebateData">

        <cfscript>
            postfix = "#qGetRebateData.compNameId#_#Replace(qGetRebateData.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#";
            postfixCompId = "#qGetRebateData.compNameId#";
            form[ "rebate_comp_" & postfix ]              = compNameId;
            form[ "rebate_uom_" & postfix ]               = uom;
            form[ "rebate_component_paid_to_" & postfix ] = Component_Paid_To;
            form[ "rebate_paymentcycle_" & postfix ]      = PaymentCycle;
            form[ "rebate_rate_" & postfix ]              = Rate;
            form[ "rebate_Claim_Mechanics_" & postfix ]   = Claim_Mechanics;
            form[ "rebate_GL_Account_ID_" & postfix ]     = GL_Account_ID;
            form[ "rebate_Vendor_Master_ID_" & postfix ]  = Vendor_Master_ID;
            form[ "rebate_Vendor_Selection_" & postfix ]  = Vendor_Selection;
            form[ "rebate_Payee_Selection_" & postfix ]   = Payee_Selection;
            form[ "rebate_scan_" & postfix ] = qGetRebateData.Scan_Percentage;

            form[ "rebate_component_paid_to_" & postfixCompId ] = Component_Paid_To;
            form[ "rebate_paymentcycle_" & postfixCompId ]      = PaymentCycle;
            form[ "rebate_Claim_Mechanics_" & postfixCompId ]   = Claim_Mechanics;
            form[ "rebate_GL_Account_ID_" & postfixCompId ]     = GL_Account_ID;
            form[ "rebate_Vendor_Master_ID_" & postfixCompId ]  = Vendor_Master_ID;
            form[ "rebate_Vendor_Selection_" & postfixCompId ]  = Vendor_Selection;
            form[ "rebate_Payee_Selection_" & postfixCompId ]   = Payee_Selection;

        </cfscript>

    </cfloop>
    <!--- rebate mappings end--->

    <!--- lump sum mappings start--->
    <cfset useLakebaseForqGetLumpSumCompId = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetlumpsumdata")>
<cfif useLakebaseForqGetLumpSumCompId>
	<cftry>
		<cfset qGetLumpSumCompId = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetlumpsumdata", {
				"select" = "compnameid,uom"
			}), "compnameid,uom"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetLumpSumCompId = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetLumpSumCompId>
<cfquery name="qGetLumpSumCompId" dbtype="query">
        SELECT 	DISTINCT compNameId, uom
        FROM	qGetLumpSumData
    </cfquery>
</cfif>

    <cfset form.lLumpSumCompIds = ValueList(qGetLumpSumCompId.compNameId) />

    <cfloop query="qGetLumpSumData">

        <cfscript>
            postfix = "#qGetLumpSumData.compNameId#_#Replace(qGetLumpSumData.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#";
            postfixCompId = "#qGetLumpSumData.compNameId#";
            form[ "lump_sum_comp_" & postfix ]              = compNameId;
            form[ "lump_sum_uom_" & postfix ]               = uom;
            form[ "lump_sum_component_paid_to_" & postfix ] = Component_Paid_To;
            form[ "lump_sum_paymentcycle_" & postfix ]      = PaymentCycle;
            form[ "lump_sum_rate_" & postfix ]              = Rate;
            form[ "lump_sum_apply_to_" & postfix ]          = Product_Option;
            form[ "lump_sum_Claim_Mechanics_" & postfix ]   = Claim_Mechanics;
            form[ "lump_sum_GL_Account_ID_" & postfix ]     = GL_Account_ID;
            form[ "lump_sum_Vendor_Master_ID_" & postfix ]  = Vendor_Master_ID;
            form[ "lump_sum_Vendor_Selection_" & postfix ]  = Vendor_Selection;
            form[ "lump_sum_Payee_Selection_" & postfix ]   = Payee_Selection;

            form[ "lump_sum_component_paid_to_" & postfixCompId ] = Component_Paid_To;
            form[ "lump_sum_paymentcycle_" & postfixCompId ]      = PaymentCycle;
            form[ "lump_sum_apply_to_" & postfixCompId ]          = Product_Option;
            form[ "lump_sum_Claim_Mechanics_" & postfixCompId ]   = Claim_Mechanics;
            form[ "lump_sum_GL_Account_ID_" & postfixCompId ]     = GL_Account_ID;
            form[ "lump_sum_Vendor_Master_ID_" & postfixCompId ]  = Vendor_Master_ID;
            form[ "lump_sum_Vendor_Selection_" & postfixCompId ]  = Vendor_Selection;
            form[ "lump_sum_Payee_Selection_" & postfixCompId ]   = Payee_Selection;
            form[ "lump_sum_component_amount_" & postfixCompId ]  = Rate;

        </cfscript>

    </cfloop>
    <!--- lump sum mappings start--->


    <cfset Form.Product_List	= ValueList(qGetProdData.BSA_Foodservice_Items_Master_ID) />
    <cfset qGetProducts			= oPlannerProgram.getproducts(Form.Product_List, form.Product_List_Type) />
    <cfif form.bCopy neq 1>
        <cfset form.Contract_Number = qGetData.Contract_Number />
    </cfif>

    <!--- Make sure discount component is lists don't have duplicates --->
    <cfset form.lFixedCompIds = request.app_general_functions.listRemoveDupes(form.lFixedCompIds, ",") />
    <cfset form.lRebateCompIds = request.app_general_functions.listRemoveDupes(form.lRebateCompIds, ",") />
    <cfset form.lLumpSumCompIds = request.app_general_functions.listRemoveDupes(form.lLumpSumCompIds, ",") />

</cfif>

<cfif (url.bInit eq 1 OR FORM.bLoadVolumeFromDB EQ 1)>

	<cfset qGetPlannerVolumeData = oPlannerProgram.getProgramPlannerVolumeData(form.programId) />
	 <cfloop index="idx" list="#form.Product_List#">

        <cfquery name="qGetVol" dbtype="query">
            SELECT	*
            FROM	qGetPlannerVolumeData
            WHERE	BSA_Foodservice_Items_Master_ID = '#idx#'
        </cfquery>

        <!--- Need to get Inventory_UM and net weight ---->
        <cfquery name="qGetNetWeightInventoryUOM" dbtype="query">
            SELECT  Inventory_UM, Net_Weight, Case_Count, Sleeves_per_case
            FROM    qGetProducts
            WHERE   BSA_Foodservice_Items_Master_ID = '#idx#'
        </cfquery>
        <cfset prodUOM = oPlannerProgram.getDefaultProductUOM(form.plTemplatedefaultUOM, form.plTemplateProddefaultUOM, qGetNetWeightInventoryUOM.Inventory_UM) />

        <cfif prodUOM eq 2>
            <cfif qGetVol.Volume_LB eq "">
                <cfset volVal = 0 />
            <cfelse>
                <cfset volVal = qGetVol.Volume_LB />
            </cfif>
        <cfelse>
            <cfif qGetVol.Volume_CS eq "">
                <cfset volVal = 0 />
            <cfelse>
                <cfset volVal = qGetVol.Volume_CS />
            </cfif>
        </cfif>

        <!--- If the “Program Volume Default UOM:” is set to “Program Template” then we need to use the default UOM from program template. Need to convert volume. --->
        <cfif form.plTemplateProgramVolumeDefaultUOM eq 2>
            <cfset volVal = oPlannerProgram.convertVolume(volVal, prodUOM, form.prgTemplateDefaultUOM, qGetNetWeightInventoryUOM.Net_Weight, qGetNetWeightInventoryUOM.Case_Count, qGetNetWeightInventoryUOM.Sleeves_per_case)  />
        </cfif>

        <cfset form["vol." & idx] = volVal />

    </cfloop>
</cfif>

<cfscript>
    // -------------------------------------------------------------------------------
    // perform similar calculation in JS to calculate lump sum amount for each product
    // -------------------------------------------------------------------------------
    // ngt
    if ( isDefined( "qGetLumpSumData" ) eq false ) {
        qGetLumpSumData = oPlannerProgram.getProgramPlannerLumpSumData( form.programId );
    }

    if ( qGetLumpSumData.recordCount and qProgramTemplate.lump_sum_allocation_method eq "component" ) {
        form.total_volume = 0;

        // gather UOMs and net weights
        cfloop ( query=qGetProducts ) {
            dash_guid = qGetProducts.BSA_Foodservice_Items_Master_ID;
            underscore_guid = qGetProducts.BSA_Foodservice_Items_Master_ID.replace( '-', '_', "all" );

            form[ "prodUom__"  & underscore_guid ] = oPlannerProgram.getDefaultProductUOM(form.plTemplatedefaultUOM, form.plTemplateProddefaultUOM, Inventory_UM);
            form[ "netWeight_" & underscore_guid ] = qGetProducts.Net_Weight;

            product_volume = round( form[ "vol." & dash_guid ] );
            //perform lump sum allocation based on planner template default uom setting
            if(form.lsAllocationUOM == 2) {
                if ( form[ "prodUOM__" & underscore_guid ] eq '1' ) {
                    //convert product volume from CS to LB
                    product_volume = product_volume * form[ "netWeight_" & underscore_guid ];
                }
            }
            else {
                if (form[ "prodUOM__" & underscore_guid ] eq '2' ) {
                    // convert product volume from LB to CS
                    product_volume = product_volume / form[ "netWeight_" & underscore_guid ];
                }

            }
            form.total_volume += product_volume;
        }

        cfloop ( query=qGetLumpSumData, group="compNameId" ) {
            running_total  = counter = 0;
            lump_sum_total = qGetLumpSumData.rate;
            // round to the same default 7 precision as in numCalc() JS function
            // call RoundToDecimalPlaces only if total_volume is not equal to 0
             if ( form.total_volume neq 0 ) {
                rate_per_uom   = RoundToDecimalPlaces( lump_sum_total / form.total_volume, 7 );
             }
             else{
                rate_per_uom   = 0;
             }

            // scan thru the same order as displayed on the page
            cfloop ( query=qGetProducts ) {
                qoq = queryExecute( "SELECT *
                                        FROM qGetLumpSumData
                                        WHERE compNameId = #qGetLumpSumData.compNameId#
                                            AND BSA_Foodservice_Items_Master_ID = '#qGetProducts.BSA_Foodservice_Items_Master_ID#' ", [], { dbtype: "query" } );
                counter += 1;

                dash_guid       = qoq.BSA_Foodservice_Items_Master_ID;
                underscore_guid = qoq.BSA_Foodservice_Items_Master_ID.replace( '-', '_', "all" );
                product_volume  = form[ "vol." & dash_guid ];

                if ( form[ "prodUOM__" & underscore_guid ] eq '1' ) {
                    product_volume = product_volume * form[ "netWeight_" & underscore_guid ];
                }
                new_lump_sum_amount = counter eq qGetProducts.recordCount
                                        ? lump_sum_total - running_total
                                        : RoundToDecimalPlaces( rate_per_uom * product_volume, 2 );
                running_total += new_lump_sum_amount;
                form[ "lump_sum_rate_" & qoq.compNameId & '_' & underscore_guid ] = new_lump_sum_amount;
            }
        }
    }
</cfscript>

<!--- If we don't have a title then default it to nickname/marketing event/performance type --->
<cfif trim(form.Contract_Title) eq "">
    <cfset form.Contract_Title = qGetPlannerProfileData.Planner_NickName />
</cfif>

<cfset useLakebaseForqCheckGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForqCheckGroup>
	<cftry>
		<cfset qCheckGroup = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"contract_main_id" = "eq.#form.programId#",
				"deleted" = "eq.0",
				"is_group" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckGroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckGroup>
<cfquery name="qCheckGroup" datasource="#application.datasource#">
    SELECT	*
    FROM	Contract_Products
    WHERE	Contract_Main_ID = '#form.programId#'
    AND		Deleted = 0
    AND		Is_Group = 1
</cfquery>
</cfif>

<cfif qCheckGroup.RecordCount>
    <cfset form.bHasGroup = 1 />
</cfif>

<cfset qCheckIsGroupItems	= oPlannerProgram.checkIfGroupItems(Form.Product_List) />
<cfset form.bIsGroupItems	= qCheckIsGroupItems />

<cfif form.bIsGroupItems eq 0>
    <cfset form.GroupLevel_1 = 0 />
</cfif>

<cfset bEDLPExists = 0 />
<cfif oPlannerProgram.existsEDLP()>
    <cfset bEDLPExists = 1 />
</cfif>

<cfset bIsEDLP = 0 />
<cfif isDefined("qGetData.Planner_Perf_Type_ID") and IsNumeric(qGetData.Planner_Perf_Type_ID)>
    <cfset bIsEDLP = oPlannerProgram.isEDLP(qGetData.Planner_Perf_Type_ID) />
</cfif>


<!--- if we are copying then reset the start and end dates --->
<cfif form.bCopy eq 1>
    <cfset form.Perf_Start_Date 	= "" />
    <cfset form.Perf_End_Date 		= "" />
    <cfset form.Delivery_Start_Date	= "" />
    <cfset form.Delivery_End_Date 	= "" />
	<cfset form.Contract_Reference_Number 	= "" />
	<cfset form.Contract_Reference_Number_2 	= "" />
</cfif>

<cfif trim(FORM.Perf_Start_Date) eq "" or trim(FORM.Delivery_Start_Date) eq "" or trim(FORM.Perf_End_Date) eq "" or trim(FORM.Delivery_End_Date) eq "">
    <cfset form.bFormIsValid = 0 />
</cfif>

<cfset form.Allow_Retro_Revision        = oGetTemplateData.Allow_Retro_Revision />
<cfset form.Allow_Retro_Revision_Span   = oGetTemplateData.Allow_Retro_Revision_Span />


<cfscript>
    if (form.bIsInDirect eq 1 and form.bFormIsValid eq 1){
        qGetProductVolumeForIndirect = oPlannerProgram.getProductVolumeForIndirect(form);
    }
</cfscript>

<cfif form.programID neq 0>
    <cfset qGetEZButtonDefaultRebateRates = oEZProgramManager.getRebateEZSettings(form.EZ_Contract_ID, Form.Product_List) />
</cfif>

<script>

    function showProductSearchWindow() {

        var bShowProd = true;
        var bIsGroupItems = document.MyForm.bIsGroupItems.value;
        var prodList = document.MyForm.Product_List.value;

        if(prodList != '' && bIsGroupItems != 0){
            bShowProd = false;
        }

        if (bShowProd == false){
            alert("Cannot add products with groups");
        }
        else{
            <cfoutput>
                popupInCenter( "/Common_Files/contracts/product_Select_V1.cfm"
                                    + "?Formname=MyForm"
                                    + "&SourceCaller=MyForm"
                                    + "&plannerId=#form.plannerId#"
                                    + "&prgID=#form.programID#"             /* wr 1114532 - fixed a program template filter problem */
                                    + "&firstParentID=#qGetData.First_Parent_ID#", "programPlannerProductWindow", 1300, 800 );
            </cfoutput>
        }
    }

    function showGroupSearchWindow()
    {
        var bShowGroup = true;
        var bIsGroupItems = document.MyForm.bIsGroupItems.value;
        var prodList = document.MyForm.Product_List.value;

        if(prodList != '' && bIsGroupItems == 0){
            bShowGroup = false;
        }

        if (bShowGroup == false){
            alert("Cannot add groups with products");
        }
        else{
            NewWindow("/Common_Files/contracts/Groups/index.cfm?formName=MyForm&programId=<cfoutput>#form.programId#&plannerId=#form.plannerId#</cfoutput>", "groupproductwindow", 800, 700, "yes", "yes");
            //document.MyForm.bSaveVolume.value = 1;
            document.MyForm.bFromGroupPopUp.value = 1;
        }
    }

    <cfoutput>
    function showComponentSelect(discountType) {
        var dt = discountType;
        var cl = document.MyForm.lLumpSumCompIds.value;
		var prodList = document.MyForm.Product_List.value;
		popupCenter2022( "/planners/create/component_select.cfm"
                                + "?Claim_Mechanics=#defaultClaimMechanics#"
                                + "&templateId=#form.templateId#"
                                + "&programId=#form.programId#"
                                + "&discountType=" + dt
                                + "&compList=" + cl
                                + "&caller=planner_program_create"
								+ "&prodExists=" + prodList.length
								, "plannercomponentselect", "SM", "LG");
    }

    function editComponent(discountType, id, componentPaidTo, paymentCycle, claimMechanics, glAccountID, vendorMasterID, vendorSelection, payeeSelection, lsApplyTo) {
        var dt = discountType;

        popupCenter2022( "/planners/create/component_select.cfm"
                                + "?templateId=#form.templateId#"
                                + "&programId=#form.programId#"
                                + "&editComp=1"
                                + "&discountType=" + dt
                                + "&compId=" + id
                                + "&Component_Paid_To=" + componentPaidTo
                                + "&PaymentCycle=" + paymentCycle
                                + "&Claim_Mechanics=" + claimMechanics
                                + "&GL_Account_ID=" + glAccountID
                                + "&Vendor_Master_ID=" + vendorMasterID
                                + "&Vendor_Selection=" + vendorSelection
                                + "&Payee_Selection=" + payeeSelection
                                + "&lump_sum_apply_to=" + lsApplyTo
                                + "&caller=planner_program_create"
                                , "plannercomponentselect", "SM", "LG" );
    }
    </cfoutput>

    function removeComponent(id, strVal, discountType) {

        var objInp;

        if (discountType == 1){
            objInp = document.MyForm.lFixedCompIds;
        }
        else if (discountType == 2){
            objInp = document.MyForm.lRebateCompIds;
        }
        else if(discountType == 3){
            objInp = document.MyForm.lLumpSumCompIds;
        }

        var str = objInp.value;
        var str2 = "";
        var aRray = str.split(",");
        var i, arrLen;

        objInp.value = "";
        arrLen = aRray.length;

        for(i=0;i<arrLen;i++)
        {
            if(aRray[i] != strVal && aRray[i] != "")
            {
                str2 = str2 + aRray[i] + ",";
            }
        }

        objInp.value = str2;
        $("tr").remove("#" + id);


        // update discount values for each product
        if (discountType == 1 || discountType == 2){
            var sProdList = document.MyForm.Product_List.value;
            var aProd = sProdList.split(",");
            var guid = '';

            for(i=0; i<aProd.length; i++)
            {
                guid = aProd[i].replace(/-/g, "_");
                discountChange(guid, 0);

            }
        }


        return;
    }

    function removeProduct(id, itemGUID, product) {
        if ( confirm("Do you wish to remove " + product + "?") ) {
            var str = document.MyForm.Product_List.value;

            var str2 = "";
            var aRray = str.split(",");
            var i, arrLen;

            $( "#customContainer" ).show();

            document.MyForm.Product_List.value = "";
            document.MyForm.ExistingProductList.value = "";

            arrLen = aRray.length;
            var product_count = 0;
            for(i=0;i<arrLen;i++)
            {
                if(aRray[i] != itemGUID && aRray[i] != "")
                {
                    product_count++;
                    str2 = str2 + aRray[i] + ",";
                }
            }

            document.MyForm.Product_List.value = str2;
            document.MyForm.ExistingProductList.value = str2;

            $("td").remove("#" + id);

            // remove all components when all products are deleted
            if ( product_count == 0 ) {
                document.MyForm.lFixedCompIds.value   = "";
                document.MyForm.lRebateCompIds.value  = "";
                document.MyForm.lLumpSumCompIds.value = "";
            }

            document.MyForm.submit();
        }
    }


</script>

<cfheader name="Cache-Control" value="no-store">
<cfheader name="expires" value="#Now()#">
<cfset Cache_Control_Header_Already_Added = 1>

<style>
    #top100 { border-bottom: 1px solid #CCC; padding-bottom: 10px; width: 100%; margin-top: 10px; display: flex; }
    #top100 > div { line-height: 26px; }
    #top102 { width: 26%; padding-left: 1%;}
    #top104 { width: 28%; margin-left: -3%; margin-right: 3%; }
    #top106 { width: 23%; margin-left: 0%; }
    #top108 { width: 23%; }

    #top100 label { text-align: right; width: 33%; display: inline-block; position: relative; padding-right: 10px; font-weight: bold; letter-spacing: 0.3px; }
    #top100 input, #top100 select { width: 45%; }
    #top100 textarea { width: 80%; }
    #top100 a { letter-spacing: 0.5px; width:90%; display2: block; padding: 0 0px 0px 25px; }
    #top100 .date { width: 21%; }

    #top102 label { width: 27%; }
    b.label { font-weight: bold; letter-spacing: 0.3px; margin-right: 1px; }
    span.tot_est_trade { margin-left: 13px; }

    #mid100 { border-bottom2: 1px solid #CCC; padding-bottom: 5px; width: 100%; height2: 500px; }
    #bot100 { width: 100%; display: none; }

    #mid100 div { float:left;  padding-bottom2: 5px; }
    #bot100 div { float:left; }


    table.pgrid { table-layout: fixed; width:100%; border-collapse:collapse; }
    table.pgrid td, table.pgrid th { padding:3px; vertical-align:middle; width:171px; min-width:171px; }
    table.pgrid th { font-weight:bold; background-color2:#ffce84; text-align:right; vertical-align:top !important; border-right:1px solid white; }
    table.pgrid th.frozen2 { background-color2: white; text-align: left; height2: 30px; vertical-align:middle; width:150px; }

    table.pgrid td.header2 { font-weight:bold; letter-spacing:0.25px; background-color2:#ffce84; text-align:right; vertical-align:top !important; }
    table.pgrid td.numeric { text-align: right !important; }
    table.pgrid td.numeric div { float:right !important; }
    td.numeric input, td.free input { width: 51%; text-align:right; }
    input.free { margin-left: 22px; }
    input.aboveMax { background-color: #ff0000; }
    input.belowMin { background-color: #ffff00; }
    input.aboveEzRate { background-color: #ff0000; }
    input.mr-md { margin-right: 7px; }

    .displayHidden {visibility:hidden;}

    .GridviewScrollHeader TH, .GridviewScrollHeader TD {
        padding: 5px;
        font-weight: bold;
        white-space: nowrap;
        border-right: 0px solid #CCC;
        border-bottom: 0px solid #CCC;
        background-color: #4F81BD;
        color: white;
        vertical-align: middle;
        height: 36px !important;
    }
    .GridviewScrollHeader div {
        margin:3px 0 0 3px;
    }

    .GridviewScrollItem TD {
        padding: 5px;
        white-space: nowrap;
        border-right: 1px dotted #CCC;
        border-bottom: 1px dotted #CCC;
        background-color: #FFFFFF;
        height: 30px !important;
    }
    .GridviewScrollPager {
        border-top: 1px solid #AAAAAA;
        background-color: #FFFFFF;
    }
    .GridviewScrollPager TD {
        padding-top: 3px;
        font-size: 14px;
        padding-left: 5px;
        padding-right: 5px;
    }
    .GridviewScrollPager A {
        color: #666666;
    }
    .GridviewScrollPager SPAN {
        font-size: 16px;
        font-weight: bold;
    }

    #pgridFreeze div { font-weight: bold !important; }
    i.cut { font-size: 1.5em; color: #00ff00; cursor: pointer;}
    a.discount { letter-spacing: 0.25px; font-weight: bold; cursor: pointer; }
    .redDisplay {  color: #ff0000;}
    .greenDisplay {  color: #008000;}
    i.volume { cursor: pointer; color:blue; width:13px; display:inline-block; }
    span.uom { display:inline-block; font-size:xx-small; margin:0; text-align:left; width:20px; -ms-filter:"progid:DXImageTransform.Microsoft.Alpha(Opacity=75)"; opacity:0.75; overflow:hidden; color:green; }
    span.unit { display:inline-block; text-align:left; margin:0; width:60px; overflow:hidden; text-align:right;}
    span.pgroup{display:inline-block; text-align:left; margin:0; overflow:hidden; text-align:left;}

    #pgridCopyFreeze {
        width: 150px;
    }
    table.pgrid {
        width: auto;
    }
    #pgridHorizontal_LIMG {
        left: 3px;
    }
    div.lump_sum_component {
        clear: both;
        margin: 2px 0 3px 20px;
    }
    input.lump_sum_component {
        width: 90px;
    }
    td.lump_sump_product {
        padding-top: 12px !important;
    }
    div.message {
        text-align: center;
        width: 100%;
        padding: 7px;
    }
    div.message span {
        display: inline-block;
        padding: 3px;
        background-color: red;
    }
    div.displayHidden {
        display: none;
    }


.filterSet {
    display: inline-block;
    vertical-align: middle;
    margin: 5px 5px 0 5px;
    background-color: #edeef2;
    border: 1px solid #c4c5c7;
    border-radius: 2px;
    padding-bottom: 1px;
    padding-top:1px;
}
.chkInput
{
	width:18px !important;
	vertical-align: middle !important;
}
.chkLabel
{
	width:115px !important;
	vertical-align: middle !important;
}
i.ls_recalc {
    font-size: 13px;
    cursor: pointer;
    color: blue;
    padding: 3px 3px 0 0;
    margin-left: 9px;
}
a.scissor {
    cursor: pointer;
    margin-right: 3px;
}
.disabled {
    pointer-events: auto;
}
</style>

<cfoutput>

    <cfset query_string = cgi.query_string>

    <!--- reset bInit to zero to avoid reloading from database --->
    <cfif listLen( query_string, '&' ) gt 0>
        <cfset query_string = replaceNoCase( query_string, "bInit=1", "bInit=0")>
    <cfelse>
        <cfset query_string = "plannerID=#form.plannerID#"
                                & "&bLock=1"
                                & "&customerID=#form.customerID#"
                                & "&templateId=#form.templateId#"
                                & "&Product_List_Type=#form.product_list_type#"
                                & "&bInit=0">
    </cfif>
    <cfset query_string = replaceNoCase( query_string, "bRevise=1", "bRevise=0")>
    <cfset query_string = replaceNoCase( query_string, "bCopy=1", "bCopy=0")>
    <!--- append original URL parameters to the action URL to avoid errors from reloading this page from component popup --->
    <!--- <form action="planner_program_create.cfm?#query_string#" method="post" name="MyForm" id="MyForm" onsubmit="preSubmit()"> --->
    <form action="planner_program_create.cfm?#query_string#" method="post" name="MyForm" id="MyForm">

        <cfif qGetData.Manual_Cancel eq 1 and form.bCopy eq 0>
            <cfset useLakebaseForqGetUserCancelled = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForqGetUserCancelled>
	<cftry>
		<cfset qGetUserCancelled = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#qGetData.Cancelled_By#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetUserCancelled = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetUserCancelled>
<cfquery name="qGetUserCancelled" datasource="#application.datasource#">
                SELECT	Name_first,name_last
                from _users
                where User_ID = '#qGetData.Cancelled_By#'
            </cfquery>
</cfif>
            <font color="red">#Application.PlannerPrgLabel# cancelled by  #qGetUserCancelled.name_first# #qGetUserCancelled.name_last# on #DateFormat(qGetData.Cancelled_Date,CF_DATE_FORMAT)#. The user cancelled the #Application.PlannerPrgLabel# using the option
            <cfif qGetData.Cancel_And_End_Dated eq 0>
                'Cancel as if it never existed'
            <cfelse>
                'Cancel as of today'
            </cfif>
            </font> <br>
        </cfif>

        <div id="top100">
            <div id="top102">
				<label>Perf Type</label>
                <select name="Planner_Perf_Types_ID" tabindex="100">
                    <cfloop query="qGetPlannerPerfTypes">
                        <cfset useLakebaseForgGetPerfData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetplannerprofiledata")>
<cfif useLakebaseForgGetPerfData>
	<cftry>
		<cfset gGetPerfData = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetplannerprofiledata", {
				"planner_perf_types_id" = "eq.#Planner_Perf_Types_ID#",
				"select" = "duration * 7 as duration,planner_delivery_days_start,planner_delivery_days_end"
			}), "duration * 7 as duration,planner_delivery_days_start,planner_delivery_days_end"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgGetPerfData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgGetPerfData>
<cfquery name="gGetPerfData" dbtype="query">
                            SELECT	Duration * 7 as Duration,
                                    Planner_Delivery_Days_Start,
                                    Planner_Delivery_Days_End
                            FROM	qGetPlannerProfileData
                            WHERE	Planner_Perf_Types_ID = #Planner_Perf_Types_ID#
                        </cfquery>
</cfif>
                        <option	value="#Planner_Perf_Types_ID#"
                            Duration="#gGetPerfData.Duration#"
                            deliveryDaysStart="#gGetPerfData.Planner_Delivery_Days_Start#"
                            deliveryDaysEnd="#gGetPerfData.Planner_Delivery_Days_End#"
                            allow_duplicate_programs="#qGetPlannerPerfTypes.allow_duplicate_programs#"
                            <cfif isDefined("qGetData.Planner_Perf_Type_ID") && qGetData.Planner_Perf_Type_ID eq qGetPlannerPerfTypes.Planner_Perf_Types_ID > selected </cfif>
                            > #Description#
                        </option>
                    </cfloop>
                </select><br>
                <!--- <label>Program ##</label> --->
                <!--- <input type="text" disabled value="#form.Contract_Number#">  --->
                <input name="Contract_Number" type="hidden" value="#form.Contract_Number#" />
                <label>Perf Dates</label>
                <input type="text" class="date start_date mr-md" name="Perf_Start_Date" value="#FORM.Perf_Start_Date#" tabindex="102">
                <input type="text" class="date" name="Perf_End_Date" value="#FORM.Perf_End_Date#" tabindex="103" />
				<cfif appSettings.get_Setting('Date_Format_Notification') EQ "1">
					<label style="text-align: left;"> <strong><font color="blue">Date Format </font></strong></label>
				</cfif>
				<br>
                <label>#plannerLabels.delivery_plural# Dates</label>
                <input type="text" class="date start_date mr-md" name="Delivery_Start_Date" value="#FORM.Delivery_Start_Date#" tabindex="104">
                <input type="text" class="date" name="Delivery_End_Date" value="#FORM.Delivery_End_Date#" tabindex="105">
				<cfif appSettings.get_Setting('Date_Format_Notification') EQ "1">
					<label style="text-align: left;"> <strong><font color="blue">MM/DD/YYYY</font></strong></label>
				</cfif>
                <cfif qGetData.Budget eq 1>
                    <cfset qGetAvailableBudgets	= oPlannerProgram.getAvailableBudgets(form.programId) />

                    <!--- If form is empty, get value from DB --->
                    <cfif form.Budget eq "">
                        <cfset qGetProgramSelectedBudgets	= oPlannerProgram.getProgramSelectedBudgets(form.programId) />
                        <cfset form.Budget = qGetProgramSelectedBudgets.Budget_ID />
                    </cfif>
                    <!--- If only single budget, set default selected --->
                    <cfif form.Budget eq "" and qGetAvailableBudgets.recordCount eq 1>
                        <cfset form.Budget = qGetAvailableBudgets.Budget_ID />
                    </cfif>
                    <label>Budget</label>
                    <select name="Budget" tabindex="106">
                        <option	value="">Select Budget</option>
                        <cfloop query="qGetAvailableBudgets">
                            <option	value="#Budget_ID#" <cfif Budget_ID eq form.Budget> selected </cfif>> #Budget_Desc#</option>
                        </cfloop>
                    </select>
                </cfif>

                <div style="text-align:center;">
                    <button class="button recommended" type="button" onclick="return validate_form();">Save</button>
                    <button onClick="return showProductSearchWindow();" type="button" class="button addLink" id="btnProd" >Add Products</button>
                    <cfif oGetTemplateData.Allow_Product_Group_Search eq 1>
                        <button onClick="return showGroupSearchWindow();" type="button" class="button addLink" id="btnProdGroups">Add Groups</button>
                    </cfif>
                </div>
				 <cfif oGetTemplateData.Planner_Program_Alternate_Customer_ON eq 1>

						 <fieldset class="filterSet">
						 	<input type="checkbox" name="AltCustomers" id="AltCustomers" value="1" class="chkInput" <cfif (form.programID EQ 0 OR request.program_in_edit_mode eq false)> disabled</cfif>
							<cfif (form.AltCustomers EQ "1")> checked</cfif>>
							<label for="chkAlt" class="chkLabel"><nobr>Alternate Customers</nobr> </label>
							<cfif (form.programID NEQ 0)>
								<cfif (qGetData.Contract_Status_Type_IDX LTE 2 AND request.program_in_edit_mode eq true) >
									<button type="button" class="button addLink alt" id="selAlt"  onclick="fnSelectAltCust('1');" <cfif (form.AltCustomers EQ "0")> disabled  </cfif>>Select</button>
								<cfelse>
									<button type="button" class="button addLink alt" id="viewAlt" onclick="fnSelectAltCust('0');" <cfif (form.AltCustomers EQ "0")> disabled  </cfif>>View</button>
								</cfif>
							<cfelse>
								<button type="button" class="button alt" id="btnDummy" disabled>Select</button>
							</cfif>
						 </fieldset>

					 </cfif>
            </div>

            <div id="top104">
            	<label>Title</label>
                <input name="Contract_Title" type="text" value="#form.Contract_Title#" tabindex="107" style="width:65% !important"/>
                <cfquery name="qCurrencies" datasource="#application.datasource#">
                    SELECT          Currency.Currency_Name
                                    ,Currency.Currency_Code
                                    ,Currency.Currency_ID
                                    ,CASE Currency.Currency_ID
                                        WHEN Program_Control_Panel_Options.CurrencyDefaultOption THEN 1
                                        ELSE 0
                                    END AS Is_Default
                        FROM        Currency_Mapping
                                    INNER JOIN Currency
                                            ON Currency.Currency_ID = Currency_Mapping.Currency_ID
                                    INNER JOIN Program_Control_Panel_Options
                                            ON Programcontrol_Panel_Options_ID = #form.templateId#
                        WHERE       Currency_Mapping.Deleted = 0 AND Currency_Mapping.Template_ID =  #form.templateId#
                        ORDER BY    Currency.Currency_Name
                </cfquery>

                <label for="">Currency</label>
                <select name="currency" tabindex="108" style="width:21% !important">
                    <cfloop query="qCurrencies">
                        <option value="#qCurrencies.Currency_ID#"
                                <cfif qCurrencies.Currency_ID eq form.currency>
                                    selected
                                <cfelseif qCurrencies.is_default>
                                    selected
                                </cfif>
                                >#qCurrencies.currency_code#</option>
                    </cfloop>
                </select><br>
            <!--- 113334	STAGE2 Planner Segment START --->
            <cfif application.util.query.get_setting("Display_Segment_Planner_Program", 0) eq "1">
                <cfset bsm_cfc = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager")>
                <cfif bsm_cfc.isEnabled()>
                    <label>Segment</label>
                    <cfset segment_config = bsm_cfc.getEnabled()>

                    <!--- disable segment dropdown when allow_segement_change is off and not a newly created program --->
                    <cfset select_disabled = ( segment_config.Allow_Segment_Change neq 1 and form.programID neq 0 ) or form.approved eq 1
                                                ? "disabled"
                                                : ''>
                    <cfquery name="qSegments" datasource="#application.datasource#">
                        /* display program template segments on newly created program */
                        <cfif select_disabled eq ''>
                            SELECT  b.Business_Segment_ID
                                   ,b.Business_Unit_Desc
                              FROM  Template_Business_Segment t
                                    INNER JOIN Business_Segment b ON t.Business_Segment_ID = b.Business_Segment_ID AND b.Active = 1 AND b.Deleted = 0
                             WHERE  t.Deleted = 0 AND t.Template_ID = '#form.templateId#'
                        <cfelse>
                            SELECT  b.Business_Segment_ID
                                   ,b.Business_Unit_Desc
                              FROM  CONTRACT_MAIN cm
                                    INNER JOIN Business_Segment b ON cm.Business_Segment_ID = b.Business_Segment_ID AND b.Active = 1 AND b.Deleted = 0
                             WHERE  cm.Contract_Main_ID = '#form.programID#'
                        </cfif>
                    </cfquery>

                    <select name="Business_Segment_ID" tabindex="109" #select_disabled#>
                        <!--- more than one program template segments are available for selection --->
                        <cfif qSegments.recordCount gt 1>
                            <option></option>
                            <cfloop query="qSegments">
                                <option value="#qSegments.Business_Segment_ID#"
                                    <cfif ( (form.Business_Segment_ID EQ 0 AND qGetPlannerData.Business_Segment_ID EQ qSegments.Business_Segment_ID) OR form.Business_Segment_ID eq qSegments.Business_Segment_ID )>selected</cfif>
                                    >#qSegments.Business_Unit_Desc#</option>
                            </cfloop>
                        <cfelse>
                            <!--- automatic selection due to segment change is not allowed or only one template segment is avaiable --->
                            <option value="#qSegments.Business_Segment_ID#" selected>#qSegments.Business_Unit_Desc#</option>
                        </cfif>
                    </select>

                    <!--- include this hidden element in form submission when segment dropdown is disabled --->
                    <cfif select_disabled neq ''>
                        <input type="hidden" name="Business_Segment_ID" value="#qSegments.Business_Segment_ID#">
                    </cfif>
                </cfif>
            </cfif>
            <!--- 113334	STAGE2 Planner Segment END --->
                <cfif qGetData.Marketing_Event eq 1>
                    <label>Marketing Event</label>
                    <input name="Marketing_Event" type="text" value="#form.Marketing_Event#" tabindex="110" />
                </cfif>
                <cfquery name="qDocuments" datasource="#application.datasource#">
                    SELECT  COUNT(1) AS Count
                    FROM    Contract_Attachments
                    WHERE   Contract_Attachments.Program_ID = #( form.programId eq 0 ? -1 : form.programId )#
                            AND Contract_Attachments.Deleted = 0
                </cfquery>
                <label>Documents</label>
                <input type="text" class="date" disabled value="#qDocuments.Count#" tabindex="111"> <i name="view_documents" title="Click to manage documents" onClick='popupInCenter("/planners/create/planner_program_documents.cfm?programId=#form.programId#", "planner_program_documents", 1000, 800)' class="ui-icon ui-icon-folder-collapsed"></i><br>
        </div>

        <div id="top106">
                <!--- Total Estimated Trade Dollars --->
                <cfif ( appSettings.getApprovalLayeredOn() or appSettings.getapprovalStandardOn() ) and appSettings.getViewProgramEstimatedAmount() eq 1>
                    <b class="label">
                        #application.PlannerEstTradeLabel# $ / Payment $
                    </b>
                    <span class="tot_est_trade">
                        #trim( Dollarformat( oPlannerProgram.getTotalEstimatedTrade( form.programID ) ) )#
                    </span>
                    /
                    <span class="tot_est_payment">
                        #trim( Dollarformat( oPlannerProgram.getTotalEstimatedPayment( form.contract_number ) ) )#
                    </span>
                    <br>
                </cfif>

                <cfif appSettings.getBudgetsFunctionalityOn()>
                    <cfset budgetReportMgr = CreateObject("component","mvc.models.Reports.BudgetReport")>
                    <cfset qbudgetReport   = budgetReportMgr.getBudgetLabels()>

                    <cfquery name="qBudgets" datasource="#application.datasource#">
                        SELECT b.Budget_Desc
                            FROM Budget_Program_Selection bps
                            INNER JOIN Budget b ON b.Budget_ID = bps.Budget_ID
                            WHERE Program_ID = '#form.programId#'
                    </cfquery>

                    <cfset budgetTotal = oPlannerProgram.getTotalBudget( form.contract_number )>

                    <cfif qBudgets.recordCount or budgetTotal.Committed neq 0 or budgetTotal.Actual neq 0>
                        <b class="label">
                            Total Budget #qbudgetReport.Committed_Dollar_Label# / #qbudgetReport.Approved_Payment_Dollar_Label#
                        </b>
                        <span class="tot_budget_comm_act">
                            #Dollarformat( budgetTotal.Committed )# / #dollarformat( budgetTotal.Actual )#
                        </span><br>
                    </cfif>
                </cfif>
                <label style="text-align:left;display:inline;vertical-align:top;">Notes</label>
                <textarea rows=3 name="notes" tabindex="112">#form.notes#</textarea>
        </div>

        <div id="top108">
                <!----LEGACY ID--->
                <cfset input_type = "hidden">
                <cfif application.util.query.get_setting("View_Legacy_ID", 0) eq 1>
                    <cfscript>
                        input_type    = "text";
                        labelComp     = CreateObject("component", "components.settings.labels.labels").init();
                        legacyIDLabel = labelComp.GetGeneralLabels('Legacy ID').General_Labels_Label;
                    </cfscript>

                    <label>#legacyIDLabel#</label>
                </cfif>
                <input type="#input_type#" name="legacy_id" tabindex="113" value="#qGetData.legacy_deal_id#">

                <label>#application.returned_customer_setting.reference_number_label#</label>
                <cfset input_type = application.returned_customer_setting.reference_number_editable ? "text" : "hidden">
                <input type="#input_type#" name="reference" tabindex="114" value="#form.Contract_Reference_Number#">

                <cfset input_type = "hidden">
                <cfif qProgramTemplate.allow_Reference_2>
                    <label>#application.returned_customer_setting.reference_number_2_label#</label>
                    <cfset input_type = "text">
                </cfif>
                <input type="#input_type#" name="reference2" tabindex="115" value="#form.Contract_Reference_Number_2#">
                <cfif form.programID neq 0>
                    <cfif qGetProgramData.recordCount and qGetProgramData.Program_Approved_Date neq ''>
                        <label>Approved on</label>
                        #dateFormat(qGetProgramData.Program_Approved_Date, "medium")#
                    </cfif>
                </cfif>
            </div>
    </div>

    <div id="mid100" class="productBody">
        <cfset nbsp_filler = " &nbsp; &nbsp; ">
        <cfset uom_filler  = "<span class=uom></span>">
        <!--- save item/group number + item description for lump sum description update --->
        <cfloop query="qGetProducts">
            <input type="hidden" name="item.#qGetProducts.BSA_Foodservice_Items_Master_ID#" value="#qGetProducts.item# - #qGetProducts.description#">
        </cfloop>
        <table class="pgrid" id="pgrid" cellspacing="0">
            <!--- <thead> --->
                <tr class="GridviewScrollHeader">
                    <th>
                        <div style="margin-top:8px;">
                            Products/Groups
                        </div>
                    </th>
                    <cfloop query="qGetProducts">
                        <th>
                            <span class="pgroup hand" title="#EncodeForHTML(qGetProducts.description)#<cfif form.bIsGroupItems><br>Click to view members</cfif>" item_key="#qGetProducts.BSA_Foodservice_Items_Master_ID#">#(qGetProducts.item eq "" ? "" : qGetProducts.item & "<br>")##EncodeForHTML(application.util.string.fullLeft(qGetProducts.description,20))#
                            </span>
                            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                            <!--- ~~~~~~~~~~~~~ remove all single quote to prevent JavaScript error in JS function call ~~~~~~~~~~~~~ --->
                            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                            <cfset product_description = replace(qGetProducts.description, "'", '', 'all')>
                            &nbsp;<a class="hand addLink" title="Click to remove product" onClick="javascript: return removeProduct('item_#item#', '#BSA_Foodservice_Items_Master_ID#', '#product_description#');"><i class="fa fa-trash-o cut"></i></a>
                        </th>
                    </cfloop> <!---  query="qGetProducts" --->
                </tr>
            <!--- </thead>
            <tbody> --->
                <!------------------>
                <!--- CASE COUNT --->
                <!------------------>
                <tr class="GridviewScrollItem">
                    <td>Weight / Case Count</td>
                    <cfloop query="qGetProducts">
                        <cfset thisStripGUID = Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") />
                        <cfif application.util.query.get_setting("Planner_Case_Count_Source", 0) eq "1">
                            <!--- Get case count from item master and not from NUC_Targets table, use value from qGetProducts query --->
                            <cfset Case_Count_Val = Case_Count />
                        <cfelse>
                            <cfquery name="qGetCaseCount" datasource="#application.datasource#">
                                SELECT	CAST(ISNULL(ISNULL(NULLIF(NUCT.Case_Count,''),CAST(im.Case_Count as decimal(10,0))),1) as INT)AS Case_Count
                                FROM	#gGetProdGroupAttr.Product_Group_Attribute_Table# TCD
                                        LEFT join BSA_Foodservice_Items_Master im
                                            ON im.#gGetProdGroupAttr.Product_Group_Attribute_Master_ID_Field# = TCD.#gGetProdGroupAttr.Product_Group_Attribute_Master_ID_Field#
                                        LEFT JOIN NUC_Targets NUCT
                                            ON TCD.#gGetProdGroupAttr.Product_Group_Attribute_Master_ID_Field# = NUCT.Product_Group_ID AND NUCT.Deleted = 0
                                WHERE	<cfif form.bIsGroupItems eq 1>
                                            TCD.#gGetProdGroupAttr.Product_Group_Attribute_Master_ID_Field# = <cfqueryparam value='#qGetProducts.BSA_Foodservice_Items_Master_ID#'>
                                        <cfelse>
                                            im.BSA_Foodservice_Items_Master_ID = <cfqueryparam value='#qGetProducts.BSA_Foodservice_Items_Master_ID#'>
                                        </cfif>
                            </cfquery>
                            <cfset Case_Count_Val = qGetCaseCount.Case_Count />
                        </cfif>


                        <td class="numeric">
                            <span class="unit numeric">#NumberFormat(Net_Weight, "_.___")# <span class="uom">#get_UOM( 2 ).Abbreviation#</span></span>
                            #uom_filler#
                            <span class="unit numeric">
                            <cfif trim(Case_Count_Val) eq "">
                                <cfset "form.bUnits_#thisStripGUID#" = 1 />
                                &nbsp;
                            <cfelse>
                                <cfset "form.bUnits_#thisStripGUID#" = Case_Count_Val />
                                #NumberFormat(Case_Count_Val, ",")# <span class="uom">EA</span>
                            </cfif>
                            </span>
                            <input type="hidden" name="bUnits_#thisStripGUID#" value="#form[ "bUnits_" & thisStripGUID ]#" />

                        </td>
                    </cfloop> <!---  query="qGetProducts" --->
                </tr>

                <!------------->
                <!--- PRICE --->
                <!------------->
                <tr class="GridviewScrollItem">
                    <td>Price</td>
                    <cfset price_elements = []>
                    <cfloop query="qGetProducts">
                        <cfset thisStripGUID = Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") />
                        <cfset prodUOM = oPlannerProgram.getDefaultProductUOM(form.plTemplatedefaultUOM, form.plTemplateProddefaultUOM, Inventory_UM) />
                        <cfset prodUOMDesc = get_UOM( 1 ).Abbreviation>
                        <cfif prodUOM eq 2>
                            <cfset prodUOMDesc = get_UOM( 2 ).Abbreviation>
                        </cfif>
                        <cfset nPrice = oPlannerProgram.getnPrice( qGetProducts.item, form.GroupLevel_1, qGetProducts.BSA_Foodservice_Items_Master_ID, form.programId, prodUOM)>
                        <cfset nUnits = form[ "bUnits_" & thisStripGUID ]>


                        <!--- EDLP --->
                        <cfif bIsEDLP>
                            <cfset nEDLPPrice = 0 />
                            <cfset nEDLPPriceUOM = 1 />
                        <cfelse>
                            <cfset qGetnEDLPPrice = oPlannerProgram.getnEDLPPrice(qGetProducts.BSA_Foodservice_Items_Master_ID, local.directPlannerId, form.Contract_Number, form.Delivery_Start_Date, form.Delivery_End_Date) />
                            <cfset nEDLPPrice = qGetnEDLPPrice.Everyday_Low_Price />
                            <cfset nEDLPPriceUOM = qGetnEDLPPrice.Everyday_Low_Price_UOM />
                        </cfif>

                        <cfif nEDLPPrice eq "">
                            <cfset nEDLPPrice = 0 />
                        </cfif>
                        <cfif prodUOM eq 1 and nEDLPPriceUOM eq 2> <!--- LB -> CS --->
                            <cfset nEDLPPrice = nEDLPPrice * Net_Weight />
                        <cfelseif prodUOM eq 2 and nEDLPPriceUOM eq 1> <!--- CS -> LB --->
                            <cfset nEDLPPrice = nEDLPPrice / Net_Weight />
                        </cfif>

                        <!---- Price in Units ---->
                        <cfset nPriceUnits = oPlannerProgram.convertFromCSToUnits(nPrice.val, nUnits, prodUOM) />

                        <cfset "form.price_#thisStripGUID#" = nPrice.val />
                        <cfset "form.prodUom__#thisStripGUID#" = prodUOM />
                        <cfset "form.prodUOMDesc__#thisStripGUID#" = prodUOMDesc />
                        <cfset "form.Inventory_UM_#thisStripGUID#" = Inventory_UM />
                        <cfset "form.case_count_#thisStripGUID#" = nUnits />
                        <cfset "form.Sleeves_per_case_#thisStripGUID#" = Sleeves_per_case />
                        <cfset "form.netWeight_#thisStripGUID#" = Net_Weight />

                        <cfset "form.edlp__#thisStripGUID#" = nEDLPPrice />
                        <cfset "form.discountSum_#thisStripGUID#" = 0 />
                        <td class="numeric">
                            <span class="unit numeric">#DollarFormat(nPrice.val)# <span class="uom">#prodUOMDesc#</span></span>
                            #uom_filler#
                            <span class="unit numeric">
                            <cfif prodUOM eq 1>
                                #DollarFormat(nPriceUnits)# <span class="uom">EA</span>
                            </cfif>
                            </span>
                            <cfsavecontent variable="price_element">
                                <input name="price_#thisStripGUID#" value="#nPrice.val#" type="hidden" />
                                <input type="hidden" name="prodUom__#thisStripGUID#" value="#prodUOM#" />
                                <input type="hidden" name="netWeight_#thisStripGUID#" value="#Net_Weight#" />
                                <input type="hidden" name="Inventory_UM_#thisStripGUID#" value="#Inventory_UM#" />
                                <input type="hidden" name="case_count_#thisStripGUID#" value="#nUnits#" />
                                <input type="hidden" name="Sleeves_per_case_#thisStripGUID#" value="#Sleeves_per_case#" />
                                <input type="hidden" name="edlp__#thisStripGUID#" value="#nEDLPPrice#" />
                            </cfsavecontent>
                            #price_element#
                            <cfset price_elements.append( price_element )>
                        </td>
                    </cfloop> <!---  query="qGetProducts" --->
                </tr>

                    <!---------------->
                    <!--- EDLP/TPR --->
                    <!---------------->
                <cfif not bIsEDLP and bEDLPExists>
                    <tr class="GridviewScrollItem">
                        <td>EDLP</td>
                        <cfloop query="qGetProducts">
                            <cfset thisStripGUID = Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") />
                            <cfset prodUOMDesc = form[ "prodUOMDesc__" & thisStripGUID] />
                            <cfset nUnits = form[ "bUnits_" & thisStripGUID] />
                            <cfset prodUOM = form[ "prodUom__" & thisStripGUID] />
                            <cfset nEDLP = form[ "edlp__" & thisStripGUID] />
                            <cfset nEDLPUnits = oPlannerProgram.convertFromCSToUnits(nEDLP, nUnits, prodUOM) />
                            <td class="numeric">
                            <span class="unit numeric">#DollarFormat(nEDLP)# <span class="uom">#prodUOMDesc#</span></span> #uom_filler#
                            <span class="unit numeric">
                            <cfif prodUOM eq 1>
                            #DollarFormat(nEDLPUnits)# <span class="uom">EA</span>
                            </cfif>
                            </span>
                            </td>
                        </cfloop> <!---  query="qGetProducts" --->
                    </tr>
                </cfif>

                <cfquery name="qTemplateRevisionSettings" datasource="#application.datasource#">
                        select      Template_Revision_Settings.*, _Users.Name_First, Name_Last
                        from        Template_Revision_Settings
                                    left join _Users on
                                    Template_Revision_Settings.Revision_Setting_Created_By =  _Users.User_ID
                        where       Revision_Setting_Deleted = 0
                        and         Template_Revision_Settings.Template_ID = <cfqueryparam value="#form.templateId#" cfsqltype="CF_SQL_INTEGER">
                </cfquery>
                <cfset UOM_Disabled = 0 />
                <cfif (form.isARevsion EQ 1 AND qTemplateRevisionSettings.Products_UOM_Changes EQ 2)>
                    <cfset UOM_Disabled = 1 />
                </cfif>

                    <!------------------->
                    <!--- FIXED PRICE --->
                    <!------------------->
                    <cfif qHasFixedComp.RecordCount>
                        <tr class="GridviewScrollItem">
                            <td><a onClick="javascript: return showComponentSelect(1);" title="Click to add fixed price" class="discount"><i class="fa fa-plus-square"></i> Fixed Price </a></td>
                            <cfloop query="qGetProducts">
                                <td>&nbsp;</td>
                            </cfloop> <!---  query="qGetProducts" --->
                        </tr>
                        <cfloop index="fixIndx" list="#form.lFixedCompIds#">
                            <cfset thisFixedId = ListGetAt(fixIndx, 1, "_") />
                            <tr id="fx_#thisFixedId#" class="GridviewScrollItem">
                                <td>
                                    <cfscript>

                                            postfixCompId = "#thisFixedId#";

                                            param name="form.fixed_component_paid_to_#postfixCompId#" default="";
                                            param name="form.fixed_paymentcycle_#postfixCompId#"      default="";
                                            param name="form.fixed_Claim_Mechanics_#postfixCompId#"   default="";
                                            param name="form.fixed_GL_Account_ID_#postfixCompId#"     default="";
                                            param name="form.fixed_Vendor_Master_ID_#postfixCompId#"  default="";
                                            param name="form.fixed_Vendor_Selection_#postfixCompId#"  default="";
                                            param name="form.fixed_Payee_Selection_#postfixCompId#"   default="";

                                            thisFixedCompPaidTo       = trim(form[ "fixed_component_paid_to_" & postfixCompId ]);
                                            thisFixedCompPaymentCycle = trim(form[ "fixed_paymentcycle_" & postfixCompId ]);
                                            thisFixedCompClaimMechanics = trim(form[ "fixed_Claim_Mechanics_" & postfixCompId ]);
                                            thisFixedCompGLAccountID = trim(form[ "fixed_GL_Account_ID_" & postfixCompId ]);

                                            thisFixedCompVendorSelection = trim(form[ "fixed_Vendor_Selection_" & postfixCompId ]);
                                            thisFixedCompPayeeSelection = trim(form[ "fixed_Payee_Selection_" & postfixCompId ]);

                                            if (thisFixedCompVendorSelection neq 1){
                                                form[ "fixed_Vendor_Master_ID_" & postfixCompId ] = 0;
                                            }

                                            thisFixedCompVendorMasterID = trim(form[ "fixed_Vendor_Master_ID_" & postfixCompId ]);

                                            qGetCompData = oProgramComponents.GetComponentDetails(thisFixedId, 1);
                                            qPaymentType = oPaymentType.get(thisFixedCompClaimMechanics);

                                            thisCompData = "";
                                            paidToDisplay = thisFixedCompPaidTo eq 1 ? '#labelManager.GetPlannerLabels('Distributor').Planner_Labels_Singular#' : '#labelManager.GetPlannerLabels('Operator').Planner_Labels_Singular#';
                                            thisCompData = thisCompData & "Paid to: #paidToDisplay# <br>";
                                            thisCompData = thisCompData & "Payment Cycle: #oPaymentCycleManager.getPaymentCycleDescription(thisFixedCompPaymentCycle)# <br>";

                                            if ( len( trim( thisFixedCompGLAccountID ) ) and trim( thisFixedCompGLAccountID ) neq 0 ) {
                                                tmpGLData    = oGLAccountManager.getComp( thisFixedCompGLAccountID );
                                                thisCompData = thisCompData & Application.GLAccountLabel & ": " & tmpGLData.GL_Account & "<br>";
                                            }

                                            thisCompData = thisCompData & "Claim Mechanic: #qPaymentType.Payment_Type_Name# <br>";
                                            tmpOIOn = qGetCompData.Off_Invoice_On eq 1 ? 'Yes' : 'No';
                                            thisCompData = thisCompData & "Off Invoice: #tmpOIOn# <br>";
                                            if (qPaymentType.Restrict_From_Billback eq 1){
                                                thisCompData = thisCompData & "Restricted from Billbacks <br>";
                                            }
                                            tmpAutoPayOn = qPaymentType.Is_Auto_Pay eq 1 ? 'Yes' : 'No';
                                            thisCompData = thisCompData & "Auto Pay: #tmpAutoPayOn# <br>";
                                            tmpAccrural = qGetCompData.Accrual_On eq 1 ? 'On' : 'Off';
                                            thisCompData = thisCompData & "Accrual: #tmpAccrural# <br>";
                                            if (trim(thisFixedCompVendorMasterID) neq 0 AND trim(thisFixedCompVendorMasterID) neq ""){
                                                tmpVendorData = oVendor.getVendorInfo(thisFixedCompVendorMasterID);
                                                thisCompData = thisCompData & "Current Payee:  #tmpVendorData.Vendor_Name#<br>";
                                            }

                                            save_hidden_input( "fixed_component_paid_to_#postfixCompId#", "#thisFixedCompPaidTo#" );
                                            save_hidden_input( "fixed_paymentcycle_#postfixCompId#", "#thisFixedCompPaymentCycle#" );
                                            save_hidden_input( "fixed_Claim_Mechanics_#postfixCompId#", "#form[ "fixed_Claim_Mechanics_" & postfixCompId ]#" );
                                            save_hidden_input( "fixed_GL_Account_ID_#postfixCompId#", "#form[ "fixed_GL_Account_ID_" & postfixCompId ]#" );
                                            save_hidden_input( "fixed_Vendor_Master_ID_#postfixCompId#", "#form[ "fixed_Vendor_Master_ID_" & postfixCompId ]#" );
                                            save_hidden_input( "fixed_Vendor_Selection_#postfixCompId#", "#form[ "fixed_Vendor_Selection_" & postfixCompId ]#" );
                                            save_hidden_input( "fixed_Payee_Selection_#postfixCompId#", "#form[ "fixed_Payee_Selection_" & postfixCompId ]#" );
                                    </cfscript>

                                    <div>
                                    <a title="Click to remove this component" onClick="javascript: return removeComponent('fx_#thisFixedId#', '#fixIndx#', 1);" class="scissor"><img src="/Images/scissor.gif" width="14" height="9" border="0"></a>
                                    <cfset qGetCompData = oProgramComponents.GetComponentDetails(thisFixedId, 1) />
                                    <a title="#thisCompData#" onClick="javascript: return editComponent(1, '#thisFixedId#','#thisFixedCompPaidTo#','#thisFixedCompPaymentCycle#','#thisFixedCompClaimMechanics#','#thisFixedCompGLAccountID#',
                                    '#thisFixedCompVendorMasterID#',
                                    '#thisFixedCompVendorSelection#',
                                    '#thisFixedCompPayeeSelection#'
                                        );">#qGetCompData.Component_Name#</a>
                                    </div>
                                </td>
                                <cfloop query="qGetProducts">
                                    <cfset thisStripGUID = Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") />
                                    <cfset prodUOM = form[ "prodUom__" & thisStripGUID] />
                                    <cfset nUnits = form[ "bUnits_" & thisStripGUID] />

                                    <td class="numeric">

                                        <cfscript>
                                            postfix = "#ListGetAt(fixIndx, 1, "_")#_#thisStripGUID#";

                                            param name="form.fixed_rate_#postfix#"              default="0";
                                            param name="form.fixed_comp_#postfix#"              default="";
                                            param name="form.fixed_uom_#postfix#"               default="";
                                            param name="form.fixed_component_paid_to_#postfix#" default="#ListFirst(thisFixedCompPaidTo)#";
                                            param name="form.fixed_paymentcycle_#postfix#"      default="#ListFirst(thisFixedCompPaymentCycle)#";
                                            param name="form.fixed_Claim_Mechanics_#postfix#"   default="#ListFirst(thisFixedCompClaimMechanics)#";
                                            param name="form.fixed_GL_Account_ID_#postfix#"     default="#ListFirst(thisFixedCompGLAccountID)#";
                                            param name="form.fixed_Vendor_Master_ID_#postfix#"  default="#ListFirst(form[ "fixed_Vendor_Master_ID_" & postfixCompId ])#";
                                            param name="form.fixed_Vendor_Selection_#postfix#"  default="#ListFirst(thisFixedCompVendorSelection)#";
                                            param name="form.fixed_Payee_Selection_#postfix#"   default="#ListFirst(thisFixedCompPayeeSelection)#";

                                            thisFixedRate         = form[ "fixed_rate_" & postfix ];
                                            thisFixedComp         = form[ "fixed_comp_" & postfix ];
                                            thisFixedUom          = form[ "fixed_uom_" & postfix ];
                                            thisFixedPaidTo       = form[ "fixed_component_paid_to_" & postfix ];
                                            thisFixedPaymentCycle = form[ "fixed_paymentcycle_" & postfix ];

                                            thisFixedRate         = ListFirst(thisFixedRate);
                                            thisFixedUom          = ListFirst(thisFixedUom);
                                        </cfscript>

                                        <cfset thisFixedSumRate = convertDiscountToUOM(1, thisFixedUom, thisFixedRate, prodUOM, form[ "price_" & thisStripGUID], qGetProducts.Net_Weight, nUnits, form[ "Sleeves_per_case_" & thisStripGUID ]) />

                                        <cfset "form.discountSum_#thisStripGUID#" = thisFixedSumRate />

                                        <cfif form[ "fixed_Vendor_Selection_" & postfix ] neq 1>
                                            <cfset form[ "fixed_Vendor_Master_ID_" & postfix ] = 0 />
                                        </cfif>

                                        <!---compNameId	rate	uom	Component_Paid_To	PaymentCycle--->
                                        <input name="fixed_comp_#postfix#" value="#thisFixedComp#" type="hidden" />
                                        <!---
                                        <input name="fixed_uom_#postfix#" value="#thisFixedUom#" type="hidden" />
                                        --->
                                        <input name="fixed_component_paid_to_#postfix#" value="#thisFixedPaidTo#" type="hidden" />
                                        <input name="fixed_paymentcycle_#postfix#" value="#thisFixedPaymentCycle#" type="hidden" />
                                        <input name="fixed_Claim_Mechanics_#postfix#" value="#form[ "fixed_Claim_Mechanics_" & postfix ]#" type="hidden" />
                                        <input name="fixed_GL_Account_ID_#postfix#" value="#form[ "fixed_GL_Account_ID_" & postfix ]#" type="hidden" />
                                        <input name="fixed_Vendor_Master_ID_#postfix#" value="#form[ "fixed_Vendor_Master_ID_" & postfix ]#" type="hidden" />
                                        <input name="fixed_Vendor_Selection_#postfix#" value="#form[ "fixed_Vendor_Selection_" & postfix ]#" type="hidden" />
                                        <input name="fixed_Payee_Selection_#postfix#" value="#form[ "fixed_Payee_Selection_" & postfix ]#" type="hidden" />
                                        $
                                        <input
                                            name="fixed_rate_#postfix#"
                                            type="text"
                                            value="#NumberFormat(thisFixedRate, rate_format( thisFixedUom ))#"
                                            class="rightColumn discountRate autoselect"
                                            guid="#thisStripGUID#"
                                            uom="#thisFixedUom#"
                                            style="width:40px"
                                            uomObjName="fixed_uom_#postfix#"
                                            netWeight="#qGetProducts.Net_Weight#"
                                            caseCount="#nUnits#"
                                            sleevesPerCase="#qGetProducts.Sleeves_per_case#"
                                            onChange="javaScript: discountChange('#thisStripGUID#', 1, '#postfix#');"
                                            <cfif not form.bFormIsValid>
                                                disabled
                                            </cfif>
                                        >
                                        <cf_uom_dropdown
                                                program_id				=	""
                                                company_main_id			=	""
                                                default_option_on		=	"0"
                                                default_option_text		=	""
                                                default_option_value	=	""
                                                dropdown_name			=	"fixed_uom_#postfix#"
                                                option_text_abbreviated	=	"1"
                                                plural_uom_display		=	""
                                                product_type_id			=	"1"
                                                program_template_id		=	"#form.templateId#"
                                                selected_uom_id			=	"#thisFixedUom#"
                                                onChange                =   "javaScript: discountChange('#thisStripGUID#', 1, '#postfix#');"
                                                uom_id_exclusion_list	=	""
                                                uom_id_inclusion_list	=	""
                                                Disabled                =   "#UOM_Disabled#"
                                            >
                                        <span class="unit numeric" id="fixedPriceUnit_#postfix#">
                                            <cfif thisFixedUom eq 1 or thisFixedUom eq 7>
                                                <cfset nFixedPriceUnits = oPlannerProgram.convertFromCSToUnits(thisFixedRate, nUnits, thisFixedUom, Sleeves_per_case) />
                                                #DollarFormat(nFixedPriceUnits)# <span class="uom">EA</span>
                                            </cfif>
                                        </span>
                                        <!---<span class="uom">#trim(oUom.getUomAbbr(thisFixedUom))#</span>--->
                                    </td>
                                </cfloop> <!---  query="qGetProducts" --->
                            </tr>
                        </cfloop>
                    </cfif> <!--- qHasFixedComp.RecordCount> --->

                    <!-------------->
                    <!--- REBATE --->
                    <!-------------->
                    <cfif qHasRebateComp.RecordCount>
                        <tr class="GridviewScrollItem">
                            <td><a onClick="javascript: return showComponentSelect(2);" title="Click to add #EncodeForHTML(plannerRebateLabel)#" class="discount"><i class="fa fa-plus-square"></i> #plannerRebateLabel# </a></td>
                            <cfloop query="qGetProducts">
                                <td>&nbsp;</td>
                            </cfloop> <!---  query="qGetProducts" --->
                        </tr>
                        <cfloop index="rebIndx" list="#form.lRebateCompIds#">
                            <cfset thisRebId = ListGetAt(rebIndx, 1, "_") />
                            <tr id="r_#thisRebId#" class="GridviewScrollItem">
                                <td>

                                <cfscript>
                                    postfixCompId = "#thisRebId#";

                                    param name="form.rebate_component_paid_to_#postfixCompId#" default="";
                                    param name="form.rebate_paymentcycle_#postfixCompId#"      default="";
                                    param name="form.rebate_Claim_Mechanics_#postfixCompId#"   default="";
                                    param name="form.rebate_GL_Account_ID_#postfixCompId#"     default="";
                                    param name="form.rebate_Vendor_Master_ID_#postfixCompId#"  default="";
                                    param name="form.rebate_Vendor_Selection_#postfixCompId#"  default="";
                                    param name="form.rebate_Payee_Selection_#postfixCompId#"   default="";
                                    param name="form.rebate_scan_#postfixCompId#"              default="";

                                    thisRebCompPaidTo = trim(form[ "rebate_component_paid_to_" & postfixCompId ]);
                                    thisRebCompPaymentCycle = trim(form[ "rebate_paymentcycle_" & postfixCompId ]);
                                    thisRebCompClaimMechanics = trim(form[ "rebate_Claim_Mechanics_" & postfixCompId ]);
                                    thisRebCompGLAccountID = trim(form[ "rebate_GL_Account_ID_" & postfixCompId ]);

                                    thisRebCompVendorSelection = trim(form[ "rebate_Vendor_Selection_" & postfixCompId ]);
                                    thisRebCompPayeeSelection = trim(form[ "rebate_Payee_Selection_" & postfixCompId ]);


                                    if (thisRebCompVendorSelection neq 1){
                                        form[ "rebate_Vendor_Master_ID_" & postfixCompId ] = 0;
                                    }

                                    thisRebCompVendorMasterID = trim(form[ "rebate_Vendor_Master_ID_" & postfixCompId ]);

                                    qGetCompData = oProgramComponents.GetComponentDetails(thisRebId, 2);
                                    qPaymentType = oPaymentType.get(thisRebCompClaimMechanics);

                                    thisCompData = "";
                                    paidToDisplay = thisRebCompPaidTo eq 1 ? '#labelManager.GetPlannerLabels('Distributor').Planner_Labels_Singular#' : '#labelManager.GetPlannerLabels('Operator').Planner_Labels_Singular#';
                                    thisCompData = thisCompData & "Paid to: #paidToDisplay# <br>";
                                    thisCompData = thisCompData & "Payment Cycle: #oPaymentCycleManager.getPaymentCycleDescription(thisRebCompPaymentCycle)# <br>";
                                    if ( len(trim(thisRebCompGLAccountID)) AND trim(thisRebCompGLAccountID) neq 0 ){
                                        tmpGLData = oGLAccountManager.getComp(thisRebCompGLAccountID);
                                        thisCompData = thisCompData & "#Application.GLAccountLabel#:  #tmpGLData.GL_Account#<br>";
                                    }
                                    thisCompData = thisCompData & "Claim Mechanic: #qPaymentType.Payment_Type_Name# <br>";
                                    tmpOIOn = qGetCompData.Off_Invoice_On eq 1 ? 'Yes' : 'No';
                                    thisCompData = thisCompData & "Off Invoice: #tmpOIOn# <br>";
                                    if (qPaymentType.Restrict_From_Billback eq 1){
                                        thisCompData = thisCompData & "Restricted from Billbacks <br>";
                                    }
                                    tmpAutoPayOn = qPaymentType.Is_Auto_Pay eq 1 ? 'Yes' : 'No';
                                    thisCompData = thisCompData & "Auto Pay: #tmpAutoPayOn# <br>";
                                    tmpAccrural = qGetCompData.Accrual_On eq 1 ? 'On' : 'Off';
                                    thisCompData = thisCompData & "Accrual: #tmpAccrural# <br>";
                                    if (trim(thisRebCompVendorMasterID) neq 0 and trim(thisRebCompVendorMasterID) neq ""){
                                        tmpVendorData = oVendor.getVendorInfo(thisRebCompVendorMasterID);
                                        thisCompData = thisCompData & "Current Payee:  #tmpVendorData.Vendor_Name#<br>";
                                    }

                                    save_hidden_input( "rebate_component_paid_to_#postfixCompId#", "#thisRebCompPaidTo#" );
                                    save_hidden_input( "rebate_paymentcycle_#postfixCompId#"     , "#thisRebCompPaymentCycle#" );
                                    save_hidden_input( "rebate_Claim_Mechanics_#postfixCompId#"  , "#form[ "rebate_Claim_Mechanics_" & postfixCompId ]#" );
                                    save_hidden_input( "rebate_GL_Account_ID_#postfixCompId#"    , "#form[ "rebate_GL_Account_ID_" & postfixCompId ]#" );
                                    save_hidden_input( "rebate_Vendor_Master_ID_#postfixCompId#" , "#form[ "rebate_Vendor_Master_ID_" & postfixCompId ]#" );
                                    save_hidden_input( "rebate_Vendor_Selection_#postfixCompId#" , "#form[ "rebate_Vendor_Selection_" & postfixCompId ]#" );
                                    save_hidden_input( "rebate_Payee_Selection_#postfixCompId#"  , "#form[ "rebate_Payee_Selection_" & postfixCompId ]#" );

                                </cfscript>

                                    <div>
                                    <a title="Click to remove this component" onClick="javascript: return removeComponent('r_#thisRebId#', '#rebIndx#', 2);" class="scissor"><img src="/Images/scissor.gif" width="14" height="9" border="0"></a>

                                    <a title="#thisCompData#" onClick="javascript: return editComponent(
                                    2,
                                    '#thisRebId#',
                                    '#thisRebCompPaidTo#',
                                    '#thisRebCompPaymentCycle#',
                                    '#thisRebCompClaimMechanics#',
                                    '#thisRebCompGLAccountID#',
                                    '#thisRebCompVendorMasterID#',
                                    '#thisRebCompVendorSelection#',
                                    '#thisRebCompPayeeSelection#'
                                        );">#qGetCompData.Component_Name#</a>
                                    </div>
                                </td>
                                <cfloop query="qGetProducts">
                                    <cfset thisStripGUID = Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") />
                                    <cfset prodUOM = form[ "prodUom__" & thisStripGUID] />
                                    <cfset nUnits = form[ "bUnits_" & thisStripGUID] />
                                    <td class="numeric">

                                        <cfscript>
                                            postfix = "#ListGetAt(rebIndx, 1, "_")#_#thisStripGUID#";

                                            param name="form.rebate_rate_#postfix#"              default="0";
                                            param name="form.rebate_comp_#postfix#"              default="";
                                            param name="form.rebate_uom_#postfix#"               default="1";
                                            param name="form.rebate_component_paid_to_#postfix#" default="#ListFirst(thisRebCompPaidTo)#";
                                            param name="form.rebate_paymentcycle_#postfix#"      default="#ListFirst(thisRebCompPaymentCycle)#";
                                            param name="form.rebate_Claim_Mechanics_#postfix#"   default="#ListFirst(thisRebCompClaimMechanics)#";
                                            param name="form.rebate_GL_Account_ID_#postfix#"     default="#ListFirst(thisRebCompGLAccountID)#";
                                            param name="form.rebate_Vendor_Master_ID_#postfix#"  default="#ListFirst(form[ "rebate_Vendor_Master_ID_" & postfixCompId ])#";
                                            param name="form.rebate_Vendor_Selection_#postfix#"  default="#ListFirst(thisRebCompVendorSelection)#";
                                            param name="form.rebate_Payee_Selection_#postfix#"   default="#ListFirst(thisRebCompPayeeSelection)#";
                                            param name="form.rebate_scan_#postfix#"              default="#form[ "rebate_scan_" & postfixCompId ]#";


                                            thisRebRate = form[ "rebate_rate_" & postfix ];
                                            thisRebComp = form[ "rebate_comp_" & postfix ];
                                            thisRebUom = form[ "rebate_uom_" & postfix ];
                                            thisRebPaidTo = form[ "rebate_component_paid_to_" & postfix ];
                                            thisRebPaymentCycle = form[ "rebate_paymentcycle_" & postfix ];
                                            qGetthisEZRateData = getEZRateData(qGetProducts.BSA_Foodservice_Items_Master_ID,2);

                                            thisEZRateVal = qGetthisEZRateData.rebate_rate;
                                            thisEZRateUOM = qGetthisEZRateData.Unit_Of_Measure_Id;

                                            thisRebRate = ListFirst(thisRebRate);
                                            thisRebUom = ListFirst(thisRebUom);
                                            param name="form.discountSum_#thisStripGUID#" default="0";

                                            thisRebateSumRate = convertDiscountToUOM(2, thisRebUom, thisRebRate, prodUOM, form["price_" & thisStripGUID], qGetProducts.Net_Weight, nUnits, form["Sleeves_per_case_" & thisStripGUID]);

                                        </cfscript>

                                        <cfif thisRebateSumRate eq "">
                                            <cfset thisRebateSumRate = 0 />
                                        </cfif>

                                        <cfset thisRebateSumRate = ltrim(rtrim(val(thisRebateSumRate))) />
                                        <cfset thisRebRate = ltrim(rtrim(val(thisRebRate))) />

                                        <cfset "form.discountSum_#thisStripGUID#" = form[ "discountSum_" & thisStripGUID] + thisRebateSumRate />

                                        <cfif form[ "rebate_Vendor_Selection_" & postfix ] neq 1>
                                            <cfset form[ "rebate_Vendor_Master_ID_" & postfix ] = 0 />
                                        </cfif>

                                        <!---compNameId	rate	uom	Component_Paid_To	PaymentCycle--->
                                        <input name="rebate_comp_#postfix#" value="#thisRebComp#" type="hidden" />
                                        <!---
                                        <input name="rebate_uom_#postfix#" value="#thisRebUom#" type="hidden" />
                                        --->

                                        <input name="rebate_comp_#postfix#" value="#thisRebComp#" type="hidden" />
                                        <input name="rebate_component_paid_to_#postfix#" value="#thisRebPaidTo#" type="hidden" />
                                        <input name="rebate_paymentcycle_#postfix#" value="#thisRebPaymentCycle#" type="hidden" />
                                        <input name="rebate_Claim_Mechanics_#postfix#" value="#form[ "rebate_Claim_Mechanics_" & postfix ]#" type="hidden" />
                                        <input name="rebate_GL_Account_ID_#postfix#" value="#form[ "rebate_GL_Account_ID_" & postfix ]#" type="hidden" />
                                        <input name="rebate_Vendor_Master_ID_#postfix#" value="#form[ "rebate_Vendor_Master_ID_" & postfix ]#" type="hidden" />
                                        <input name="rebate_Vendor_Selection_#postfix#" value="#form[ "rebate_Vendor_Selection_" & postfix ]#" type="hidden" />
                                        <input name="rebate_Payee_Selection_#postfix#" value="#form[ "rebate_Payee_Selection_" & postfix ]#" type="hidden" />

                                        $
                                        <input
                                            name="rebate_rate_#postfix#"
                                            type="text"
                                            value="#NumberFormat(thisRebRate, rate_format( thisRebUom ))#"
                                            class="rightColumn discountRate autoselect"
                                            style="width:40px"
                                            guid="#thisStripGUID#"
                                            uom="#thisRebUom#"
                                            uomObjName="rebate_uom_#postfix#"
                                            netWeight="#qGetProducts.Net_Weight#"
                                            caseCount="#nUnits#"
                                            sleevesPerCase="#qGetProducts.Sleeves_per_case#"
                                            onChange="javaScript: discountChange('#thisStripGUID#', 2, '#ListGetAt(rebIndx, 1, "_")#_#thisStripGUID#');"
                                            <cfif not form.bFormIsValid>
                                                disabled
                                            </cfif>
                                            ezRate="#NumberFormat(thisEZRateVal, rate_format( thisEZRateUOM ))#"
                                            ezRateUOM="#thisEZRateUOM#"
                                        >
                                            <cf_uom_dropdown
                                                program_id				=	""
                                                company_main_id			=	""
                                                default_option_on		=	"0"
                                                default_option_text		=	""
                                                default_option_value	=	""
                                                dropdown_name			=	"rebate_uom_#postfix#"
                                                option_text_abbreviated	=	"1"
                                                plural_uom_display		=	""
                                                product_type_id			=	"2"
                                                program_template_id		=	"#form.templateId#"
                                                selected_uom_id			=	"#thisRebUom#"
                                                onChange                =   "javaScript: discountChange('#thisStripGUID#', 2, '#ListGetAt(rebIndx, 1, "_")#_#thisStripGUID#');"
                                                uom_id_exclusion_list	=	""
                                                uom_id_inclusion_list	=	""
                                                Disabled                =   "#UOM_Disabled#"
                                            >
                                        <span class="unit numeric" id="rebateUnit_#ListGetAt(rebIndx, 1, "_")#_#thisStripGUID#">
                                            <cfif thisRebUom eq 1 or thisRebUom eq 7>
                                                <cfset nRebateUnits = oPlannerProgram.convertFromCSToUnits(thisRebRate, nUnits, thisRebUom, Sleeves_per_case) />
                                                #NumberFormat(nRebateUnits, "_.__")# <span class="uom">EA</span>
                                            </cfif>
                                        </span>
                                        <!---<span class="uom">#thisRebUom#</span>--->
                                        <cfif listFind(valueList(qScanRedemptions.Program_Rebates_Component_Name_ID), thisRebId)>
                                            <div style="width:132%;text-align:left;margin-top:5px">
                                                <input
                                                    name="rebate_scan_#postfix#"
                                                    type="text"
                                                    value="#form[ 'rebate_scan_#postfix#' ]#"
                                                    class="rightColumn discountRate autoselect rebate_scan"
                                                    style="width:40px;margin-left:72px"
                                                >%
                                            </div>
                                        </cfif>
                                        <!--- <select></select>
                                        <span class="unit numeric">
                                            <span class="uom"></span>
                                        </span> --->
                                    </td>
                                </cfloop> <!---  query="qGetProducts" --->
                            </tr>
                        </cfloop>
                    </cfif>

                    <!---------------->
                    <!--- LUMP SUM --->
                    <!---------------->
                    <cfif qHasLumpComp.RecordCount>
                        <tr class="GridviewScrollItem">
                            <cfparam name="plannerLabels.lump_sum_singular" default="Lump Sum">
                            <td><a onClick="javascript: return showComponentSelect(3);" class="discount" title="Click to add #plannerLabels.lump_sum_singular#"><i class="fa fa-plus-square"></i> #plannerLabels.lump_sum_singular#</a></td>
                            <cfloop query="qGetProducts">
                                <td>&nbsp;</td>
                            </cfloop> <!---  query="qGetProducts" --->
                        </tr>
                        <cfloop index="lsIndx" list="#form.lLumpSumCompIds#">
                            <cfset thisLsId = listFirst( lsIndx, "_" )>
                            <tr id="ls_#thisLsId#" class="GridviewScrollItem">
                                <td>
                                    <cfscript>
                                        postfixCompId = "#thisLsId#";

                                        param name="form.lump_sum_component_paid_to_#postfixCompId#" default="";
                                        param name="form.lump_sum_paymentcycle_#postfixCompId#" default="";
                                        param name="form.lump_sum_apply_to_#postfixCompId#" default="";
                                        param name="form.lump_sum_Claim_Mechanics_#postfixCompId#" default="";
                                        param name="form.lump_sum_GL_Account_ID_#postfixCompId#" default="";
                                        param name="form.lump_sum_Vendor_Master_ID_#postfixCompId#" default="";
                                        param name="form.lump_sum_Vendor_Selection_#postfixCompId#" default="";

                                        thisLsCompPaidTo =  trim(form[ "lump_sum_component_paid_to_" & postfixCompId ]);
                                        thisLsCompPaymentCycle =  trim(form[ "lump_sum_paymentcycle_" & postfixCompId ]);
                                        thisLsCompApplyTo =  trim(form[ "lump_sum_apply_to_" & postfixCompId ]);
                                        thisLsCompClaimMechanics =  trim(form[ "lump_sum_Claim_Mechanics_" & postfixCompId ]);
                                        thisLsCompGLAccountID =  trim(form[ "lump_sum_GL_Account_ID_" & postfixCompId ]);
                                        thisLsCompVendorMasterID =  trim(form[ "lump_sum_Vendor_Master_ID_" & postfixCompId ]);
                                        thisLsCompVendorSelection =  trim(form[ "lump_sum_Vendor_Selection_" & postfixCompId ]);

                                        qGetCompData = oProgramComponents.GetComponentDetails(thisLsId, 3);
                                        qPaymentType = oPaymentType.get(thisLsCompClaimMechanics);

                                        thisCompData = "";
                                        paidToDisplay = thisLsCompPaidTo eq 1 ? '#labelManager.GetPlannerLabels('Distributor').Planner_Labels_Singular#' : '#labelManager.GetPlannerLabels('Operator').Planner_Labels_Singular#';
                                        thisCompData = thisCompData & "Paid to: #paidToDisplay# <br>";
                                        thisCompData = thisCompData & "Payment Cycle: #oPaymentCycleManager.getPaymentCycleDescription(thisLsCompPaymentCycle)# <br>";
                                        if (trim(thisLsCompGLAccountID) neq 0){
                                            tmpGLData = oGLAccountManager.getComp(thisLsCompGLAccountID);
                                            thisCompData = thisCompData & "#Application.GLAccountLabel#:  #tmpGLData.GL_Account#<br>";
                                        }
                                        thisCompData = thisCompData & "Claim Mechanic: #qPaymentType.Payment_Type_Name# <br>";
                                        tmpOIOn = qGetCompData.Off_Invoice_On eq 1 ? 'Yes' : 'No';
                                        thisCompData = thisCompData & "Off Invoice: #tmpOIOn# <br>";
                                        if (qPaymentType.Restrict_From_Billback eq 1){
                                            thisCompData = thisCompData & "Restricted from Billbacks <br>";
                                        }
                                        tmpAutoPayOn = qPaymentType.Is_Auto_Pay eq 1 ? 'Yes' : 'No';
                                        thisCompData = thisCompData & "Auto Pay: #tmpAutoPayOn# <br>";
                                        tmpAccrural = qGetCompData.Accrual_On eq 1 ? 'On' : 'Off';
                                        thisCompData = thisCompData & "Accrual: #tmpAccrural# <br>";
                                        if (trim(thisLsCompVendorMasterID) neq 0 and trim(thisLsCompVendorMasterID) neq ""){
                                            tmpVendorData = oVendor.getVendorInfo(thisLsCompVendorMasterID);
                                            thisCompData = thisCompData & "Current Payee:  #tmpVendorData.Vendor_Name#<br>";
                                        }

                                        save_hidden_input( "lump_sum_component_paid_to_#postfixCompId#", "#thisLsCompPaidTo#" );
                                        save_hidden_input( "lump_sum_paymentcycle_#postfixCompId#", "#thisLsCompPaymentCycle#" );
                                        save_hidden_input( "lump_sum_apply_to_#postfixCompId#", "#thisLsCompApplyTo#" );
                                        save_hidden_input( "lump_sum_Claim_Mechanics_#postfixCompId#", "#form[ "lump_sum_Claim_Mechanics_" & postfixCompId ]#" );
                                        save_hidden_input( "lump_sum_GL_Account_ID_#postfixCompId#", "#form[ "lump_sum_GL_Account_ID_" & postfixCompId ]#" );
                                        save_hidden_input( "lump_sum_Vendor_Master_ID_#postfixCompId#", "#form[ "lump_sum_Vendor_Master_ID_" & postfixCompId ]#" );
                                        save_hidden_input( "lump_sum_Vendor_Selection_#postfixCompId#", "#form[ "lump_sum_Vendor_Selection_" & postfixCompId ]#" );
                                    </cfscript>

                                    <div>
                                    <a title="Click to remove this component" onClick="javascript: return removeComponent('ls_#thisLsId#', '#lsIndx#', 3);" class="scissor"><img src="/images/scissor.gif" width="14" height="9" border="0"></a>
                                    <cfset qGetCompData = oProgramComponents.GetComponentDetails(thisLsId, 3) />
                                    <a title="#thisCompData#" onClick="javascript: return editComponent(
                                                                                    3,
                                                                                    '#thisLsId#',
                                                                                    '#thisLsCompPaidTo#',
                                                                                    '#thisLsCompPaymentCycle#',
                                                                                    '#thisLsCompClaimMechanics#',
                                                                                    '#thisLsCompGLAccountID#',
                                                                                    '#thisLsCompVendorMasterID#',
                                                                                    '#thisLsCompVendorSelection#',
                                                                                    '',
                                                                                    '#thisLsCompApplyTo#'
                                                                                        );">#qGetCompData.Component_Name#</a>
                                    </div>
                                    <!--- lump sum component total --->
                                    <div class="lump_sum_component">
                                        <!--- ngt --->
                                        <cfscript>
                                            ls_attributes = "";
                                            ls_amount     = replace( form[ 'lump_sum_component_amount_#postfixCompId#' ], ',', '', "all" );

                                            if ( qProgramTemplate.Lump_Sum_Allocation_Method is "Component_Product" ) {
                                                // ngt
                                                ls_amount = 0;
                                                // total up all individual product lump sum amounts for this component
                                                for ( product in qGetProducts ) {
                                                    postfix = replace( "#thisLsId#_#product.BSA_Foodservice_Items_Master_ID#", '-', '_', "all" );
                                                    param name="form.lump_sum_rate_#postfix#" default="0";
                                                    ls_amount += form[ "lump_sum_rate_" & postfix ];
                                                }
                                                ls_attributes = "readonly disabled";
                                            }

                                            ls_attributes = ls_attributes & " value='" & numberFormat( ls_amount, ',.__' ) & "'";
                                        </cfscript>

                                        <!--- use "lump_sum" attribute to find product lump sum amount elements for the same component --->
                                        $ <input name="lump_sum_component_amount_#postfixCompId#"
                                                type="text" class="lump_sum_component autoselect" style="text-align:right"
                                                #ls_attributes#
                                                lump_sum="#postfixCompId#">

                                        <cfif ( qProgramTemplate.Lump_Sum_Allocation_Method is "Component_Product" )>
                                            <cfif request.program_in_edit_mode>
                                                &nbsp; <i class="fa fa-refresh ls_recalc" lump_sum="#postfixCompId#" title="Click to reallocate based on volumes">&nbsp;</i>
                                            </cfif>

                                            <cfif ls_attributes.findNoCase( " disabled " )>
                                                <!--- disabled element excluded from form submission, create a hidden element for it --->
                                                <input name="lump_sum_component_amount_#postfixCompId#"
                                                        type="hidden" class="lump_sum_component autoselect"
                                                        value="#ls_amount#"
                                                        lump_sum="#postfixCompId#">
                                            </cfif>
                                        </cfif>
                                    </div>
                                </td>

                                <cfloop query="qGetProducts">
                                    <td class="numeric lump_sump_product">
                                        <cfscript>
                                            thisStripGUID = Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL");
                                            postfix = "#ListGetAt(lsIndx, 1, "_")#_#thisStripGUID#";

                                            param name="form.lump_sum_rate_#postfix#" default="0";
                                            param name="form.lump_sum_comp_#postfix#" default="";
                                            param name="form.lump_sum_uom_#postfix#" default="";
                                            param name="form.lump_sum_component_paid_to_#postfix#" default="#ListFirst(thisLsCompPaidTo)#";
                                            param name="form.lump_sum_paymentcycle_#postfix#" default="#ListFirst(thisLsCompPaymentCycle)#";
                                            param name="form.lump_sum_apply_to_#postfix#" default="#ListFirst(thisLsCompApplyTo)#";
                                            param name="form.lump_sum_Claim_Mechanics_#postfix#" default="#ListFirst(thisLsCompClaimMechanics)#";
                                            param name="form.lump_sum_GL_Account_ID_#postfix#" default="#ListFirst(thisLsCompGLAccountID)#";
                                            param name="form.lump_sum_Vendor_Master_ID_#postfix#" default="#ListFirst(thisLsCompVendorMasterID)#";
                                            param name="form.lump_sum_Vendor_Selection_#postfix#" default="#ListFirst(thisLsCompVendorSelection)#";

                                            thisLsRate = "#evaluate("form.lump_sum_rate_#postfix#")#";
                                            thisLsComp = "#evaluate("form.lump_sum_comp_#postfix#")#";
                                            thisLsUom = "#evaluate("form.lump_sum_uom_#postfix#")#";
                                            thisLsPaidTo = "#evaluate("form.lump_sum_component_paid_to_#postfix#")#";
                                            thisLsPaymentCycle = "#evaluate("form.lump_sum_paymentcycle_#postfix#")#";
                                            thisLsApplyLumpSumTo = "#evaluate("form.lump_sum_apply_to_#postfix#")#";
                                            thisLsRate = ListFirst(thisLsRate);
                                            thisLsUom = ListFirst(thisLsUom);

                                            "form.discountLSSum_#thisStripGUID#" = 0;

                                            thisLsRate = ltrim(rtrim(val(thisLsRate)));
                                            thisLsSumRate = thisLsRate;

                                            form[ "discountLSSum_#thisStripGUID#" ] = form[ "discountLSSum_" & thisStripGUID] + thisLsSumRate;
                                        </cfscript>

                                        <!---compNameId	rate	uom	Component_Paid_To	PaymentCycle--->
                                        <input name="lump_sum_comp_#postfix#" value="#thisLsComp#" type="hidden" />
                                        <input name="lump_sum_uom_#postfix#" value="#thisLsUom#" type="hidden" />
                                        <input name="lump_sum_component_paid_to_#postfix#" value="#thisLsPaidTo#" type="hidden" />
                                        <input name="lump_sum_paymentcycle_#postfix#" value="#thisLsPaymentCycle#" type="hidden" />
                                        <input name="lump_sum_apply_to_#postfix#" value="#thisLsApplyLumpSumTo#" type="hidden" />
                                        <input name="lump_sum_Claim_Mechanics_#postfix#" value="#form[ "lump_sum_Claim_Mechanics_" & postfix ]#" type="hidden" />
                                        <input name="lump_sum_GL_Account_ID_#postfix#" value="#form[ "lump_sum_GL_Account_ID_" & postfix ]#" type="hidden" />
                                        <input name="lump_sum_Vendor_Master_ID_#postfix#" value="#form[ "lump_sum_Vendor_Master_ID_" & postfix ]#" type="hidden" />
                                        <input name="lump_sum_Vendor_Selection_#postfix#" value="#form[ "lump_sum_Vendor_Selection_" & postfix ]#" type="hidden" />
                                        <!--- use "guid" attribute to find product lump sum amount elements for the same product --->
                                        $
                                        <input
                                            type="text"
                                            lump_sum="#postfixCompId#"
                                            guid="#thisStripGUID#"
                                            <cfif qProgramTemplate.Lump_Sum_Allocation_Method is "Component">
                                                name="lump_sum_rate_#postfix#_disabled"
                                                disabled="disabled"
                                                readonly
                                            <cfelse>
                                                name="lump_sum_rate_#postfix#"
                                                value="#NumberFormat(thisLsRate, "_.__")#"
                                                class="rightColumn discountRate autoselect ls_prod"
                                            </cfif>
                                        >
                                        <span class="unit numeric">
                                            #uom_filler#
                                        </span>

                                    </td>
                                </cfloop> <!---  query="qGetProducts" --->
                            </tr>
                        </cfloop>
                    </cfif>

                    <!-------------->
                    <!--- VOLUME --->
                    <!-------------->
                    <tr class="GridviewScrollItem">
                        <td>Volume</td>
                        <cfloop query="qGetProducts">
                            <cfset thisStripGUID = Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") />
                            <cfset prodUOMDesc = form[ "prodUOMDesc__" & thisStripGUID] />
                            <cfset prodUOMID = form[ "prodUOM__" & thisStripGUID] />
                            <cfif structKeyExists(form, "vol." & qGetProducts.BSA_Foodservice_Items_Master_ID)>
                                <cfset input_value = replace(form[ 'vol.' & qGetProducts.BSA_Foodservice_Items_Master_ID ],",", "", "all") />
                            <cfelse>
                                <cfset prodUOM = form[ "prodUom__" & thisStripGUID] />
                                <cfif not form.bFormIsValid>
                                    <cfset input_value = 0 />
                                <cfelseif form.bIsInDirect eq 1>
                                    <cfquery name="qGetThisVolume" dbtype="query">
                                        SELECT 	Cases, Pounds
                                        FROM	qGetProductVolumeForIndirect
                                        WHERE	BSA_Foodservice_Items_Master_ID = '#qGetProducts.BSA_Foodservice_Items_Master_ID#'
                                    </cfquery>
                                    <cfif prodUOM eq 2>
                                        <cfset input_value = qGetThisVolume.Pounds />
                                    <cfelse>
                                        <cfset input_value = qGetThisVolume.Cases />
                                    </cfif>
                                    <cfif input_value eq "">
                                        <cfset input_value = 1 />
                                    </cfif>
                                <cfelse>
                                    <cfset qGetProductVolumeFromVolumePlan = oPlannerProgram.getProductVolumeFromVolumePlan(form.programId, qGetProducts.BSA_Foodservice_Items_Master_ID) />
                                    <cfif prodUOM eq 2>
                                        <cfset input_value = qGetProductVolumeFromVolumePlan.forecast_lb />
                                    <cfelse>
                                        <cfset input_value = qGetProductVolumeFromVolumePlan.forecast_cs />
                                    </cfif>
                                </cfif>
                                <cfset input_value = replace(input_value,",", "", "all") />
                                <!--- If the “Program Volume Default UOM:” is set to “Program Template” then we need to convert the input value to the Program Template default UOM. --->
                                <cfif form.plTemplateProgramVolumeDefaultUOM eq 2>
                                    <cfset input_value = oPlannerProgram.convertVolume(input_value, prodUOM, form.prgTemplateDefaultUOM, Net_Weight, Case_Count, Sleeves_per_case)  />
                                </cfif>
                            </cfif>
                            <!--- If the “Program Volume Default UOM:” is set to “Program Template” then we need to get the correct UOM description. --->
                            <cfif form.plTemplateProgramVolumeDefaultUOM eq 2>
                                <cfset prodUOMID = form.prgTemplateDefaultUOM />
                                <cfset prodUOMDesc = "#get_UOM( form.prgTemplateDefaultUOM ).Abbreviation#" />
                            </cfif>

                            <td class="numeric">
                                <input	type="text"
                                        class="lfc autoselect"
                                        name="vol.#qGetProducts.BSA_Foodservice_Items_Master_ID#"
                                        value="#NumberFormat(input_value)#"
                                        uom="#trim(prodUOMDesc)#"
                                        net_weight="#Net_Weight#"
                                        <cfif not form.bFormIsValid>
                                            disabled
                                        </cfif>
                                        uomId="#prodUOMID#"
                                >
                                <input type="hidden" name="volChange#qGetProducts.BSA_Foodservice_Items_Master_ID#" value="0">
                                <span class="unit numeric">
                                    <span class="uom">#prodUOMDesc#</span>
                                    <cfif form.bIsInDirect eq 0>
                                        <i class="fa fa-bars volume" title="Click to view #lcase( Application.PlannerPrgLabel )# volume"></i>
                                    </cfif>#uom_filler##uom_filler##uom_filler#
                                </span>

                            </td>
                        </cfloop> <!---  query="qGetProducts" --->
                    </tr>

                    <cfif qGetData.recordCount>
                        <cfset useLakebaseForqPerformType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetplannerperftypes")>
<cfif useLakebaseForqPerformType>
	<cftry>
		<cfset qPerformType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetplannerperftypes", {
				"planner_perf_types_id" = "eq.#qGetData.Planner_Perf_Type_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqPerformType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqPerformType>
<cfquery name="qPerformType" dbtype="query">
                            SELECT *
                            FROM qGetPlannerPerfTypes
                            WHERE qGetPlannerPerfTypes.planner_perf_types_id = #qGetData.Planner_Perf_Type_ID#
                        </cfquery>
</cfif>

                        <cfif qPerformType.Slotting eq '1'>
                            <!------------------>
                            <!--- FREE CASES --->
                            <!------------------>
                            <tr class="GridviewScrollItem" id="tr_free_cases">
                                <td>Free Cases</td>
                                <cfloop query="qGetProducts">
                                    <cfset thisStripGUID = Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") />
                                    <cfset useLakebaseForqUnitprice = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetunitpricedata")>
<cfif useLakebaseForqUnitprice>
	<cftry>
		<cfset qUnitprice = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetunitpricedata", {
				"group_id" = "eq.#qGetProducts.BSA_Foodservice_Items_Master_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUnitprice = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUnitprice>
<cfquery name="qUnitprice" dbtype="query">
                                        SELECT 	*
                                        FROM	qGetUnitPriceData
                                        WHERE	Group_ID = '#qGetProducts.BSA_Foodservice_Items_Master_ID#'
                                    </cfquery>
</cfif>
                                    <td class="free">
                                        <input	type="text"
                                                class="free autoselect"
                                                name="free_cases__#thisStripGUID#"
                                                value="#NumberFormat( qUnitprice.free_cases )#"
                                                <cfif not form.bFormIsValid>
                                                    disabled
                                                </cfif>
                                        >
                                    </td>
                                </cfloop> <!---  query="qGetProducts" --->
                            </tr>
                        </cfif>
                    </cfif>

                    <!----------->
                    <!--- UOM --->
                    <!----------->
                    <tr class="GridviewScrollItem">
                        <td style="background-color:##CCCCCC;border-right:1px solid white;">UOM</td>
                        <cfloop query="qGetProducts">
                            <cfset thisStripGUID = Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") />
                            <cfset prodUOM = form[ "prodUom__" & thisStripGUID] />
                            <cfset nPrice = form[ "price_" & thisStripGUID]>
                            <!--- TODO: Substitute the number 2 below with the real units per CS from the DB ---->
                            <cfset nUnits = form[ "bUnits_" & thisStripGUID]>

                            <cfset nEDLPPrice = form[ "edlp__" & thisStripGUID] />


                            <cfparam name="form.discountSum_#thisStripGUID#" default="0" />
                            <cfparam name="form.nucval__#thisStripGUID#" default="0" />
                            <cfif form[ "discountSum_" & thisStripGUID] eq "">
                                <cfset "form.discountSum_#thisStripGUID#" = 0 />
                            </cfif>

                            <!--------------  Retailer Unit Cost ---------->
                            <cfset rucCalc =  (nPrice - form[ "discountSum_" & thisStripGUID] - nEDLPPrice) />

                            <cfif prodUOM eq 2> <!--- LB -> LB --->
                                <cfset ruc = rucCalc />
                            <cfelse> <!---- CS -> Units --->
                                <cfif rucCalc eq 0 or rucCalc eq "" or nUnits eq 0>
                                    <cfset ruc = 0 />
                                <cfelse>
                                    <cfset ruc = rucCalc / nUnits />
                                </cfif>
                            </cfif>

                            <cfset "form.rucval__#thisStripGUID#" = ruc />

                            <cfif form[ "rucval__" & thisStripGUID] eq "">
                                <cfset "form.rucval__#thisStripGUID#" = 0 />
                            </cfif>


                            <!--------------  Retailer Unit Cost LS ---------->
                            <cfset nVolume = structKeyExists(form, "vol." & qGetProducts.BSA_Foodservice_Items_Master_ID) ? replace(form[ 'vol.' & qGetProducts.BSA_Foodservice_Items_Master_ID ],",", "") : 1>
                            <cfset nVolume = replace(nVolume, ",", "", "all") />

                            <cfif nVolume eq 0>
                                <cfset nVolume = 1 />
                            </cfif>
                            <cfparam name="form.discountLSSum_#thisStripGUID#" default="0" />
                            <cfset nAllSum = form[ "discountSum_" & thisStripGUID] + (form[ "discountLSSum_" & thisStripGUID] / nVolume) />
                            <cfset calcRucLs = (nPrice - nAllSum) - nEDLPPrice />
                            <cfif calcRucLs eq 0 or calcRucLs eq "" or nUnits eq 0 or form[ "discountLSSum_" & thisStripGUID] eq 0>
                                <cfset rucLs = ruc />
                            <cfelse>
                                <cfset rucLs = calcRucLs / nUnits />

                            </cfif>
                            <cfset "form.rucvalLS__#thisStripGUID#" = rucLs />

                            <!--------------  NUC ---------->
                            <cfquery name="qGetNUCTarget" datasource="#application.datasource#">
                                SELECT	NUCT.Promoted_NUC, NUCT.Promoted_NUC_UOM
                                FROM	#gGetProdGroupAttr.Product_Group_Attribute_Table# TCD
                                        LEFT join BSA_Foodservice_Items_Master im on im.#gGetProdGroupAttr.Product_Group_Attribute_Master_ID_Field# = TCD.#gGetProdGroupAttr.Product_Group_Attribute_Master_ID_Field#
                                        LEFT JOIN NUC_Targets NUCT ON TCD.#gGetProdGroupAttr.Product_Group_Attribute_Master_ID_Field# = NUCT.Product_Group_ID AND NUCT.Deleted = 0
                                WHERE	<cfif form.bIsGroupItems eq 1>TCD.#gGetProdGroupAttr.Product_Group_Attribute_Master_ID_Field# = <cfqueryparam value='#qGetProducts.BSA_Foodservice_Items_Master_ID#'> <cfelse>im.BSA_Foodservice_Items_Master_ID = <cfqueryparam value='#qGetProducts.BSA_Foodservice_Items_Master_ID#'></cfif>
                            </cfquery>

                            <cfparam name="form.nucval__#thisStripGUID#" default="0" />
                            <cfset nucval = qGetNUCTarget.Promoted_NUC />
                            <cfset nucUom = qGetNUCTarget.Promoted_NUC_UOM />

                            <cfif prodUOM eq 1 and nucUom eq 1> <!--- CS -> Units --->
                                <cfset nucval = nucval / nUnits />
                            <cfelseif prodUOM eq 1 and nucUom eq 2> <!--- LB -> Units --->
                                <cfset nucval = nucval * Net_Weight / nUnits />
                            <cfelseif prodUOM eq 1 and nucUom eq 5> <!--- CS -> Units --->
                                <cfset nucval = nucval />
                            <cfelseif prodUOM eq 2 and nucUom eq 1> <!--- CS -> LB --->
                                <cfset nucval = nucval / Net_Weight />
                            <cfelseif prodUOM eq 2 and nucUom eq 2> <!--- LB -> LB --->
                                <cfset nucval = nucval />
                            <cfelseif prodUOM eq 2 and nucUom eq 5> <!--- LB -> Units --->
                                <cfset nucval = nucval / Net_Weight * nUnits />
                            </cfif>

                            <cfset "form.nucval__#thisStripGUID#" = nucval />

                            <cfif form[ "nucval__" & thisStripGUID] eq "">
                                <cfset "form.nucval__#thisStripGUID#" = 0 />
                            </cfif>

                            <td style="text-align:right;background-color:##CCCCCC;border-right:1px solid white;"><cfif prodUOM eq 2>#get_UOM( 2 ).Abbreviation#<cfelse>EA</cfif> #uom_filler#
                            <input type="hidden" name="discountSum_#thisStripGUID#" value="#form[ "discountSum_" & thisStripGUID]#" />
                            <input type="hidden" name="discountLSSum_#thisStripGUID#" value="#form[ "discountLSSum_" & thisStripGUID]#" />
                            <input type="hidden" name="rucval__#thisStripGUID#" value="#ruc#" />
                            <input type="hidden" name="nucval__#thisStripGUID#" value="#form[ "nucval__" & thisStripGUID]#" />
                            </td>
                        </cfloop> <!---  query="qGetProducts" --->
                    </tr>

                    <!-------------------->
                    <!--- PROMOTED NUC --->
                    <!-------------------->
                    <!--- Display NUC Target if template setting is on --->
                    <cfif qGetData.NUC_Target eq 1>
                        <tr class="GridviewScrollItem" id="PromotedNuc">
                            <td>Promoted NUC Target</td>
                            <cfloop query="qGetProducts">
                                <cfset thisStripGUID = Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") />
                                <td class="numeric">#DollarFormat(form["nucval__" & thisStripGUID])# #uom_filler#</td>
                            </cfloop> <!---  query="qGetProducts" --->
                        </tr>
                    </cfif>   <!--- <cfif qGetData.NUC_Target eq 1> --->

                    <!-------------------------->
                    <!--- RETAILER UNIT COST --->
                    <!-------------------------->
                    <!--- Display Retailer Unit Cost if template setting is on --->
                    <cfif qGetData.Retailer_Unit_Cost eq 1>
                        <tr class="GridviewScrollItem" id="RetailerUnitCost">
                            <td>Retailer Unit Cost</td>
                            <cfloop query="qGetProducts">
                                <cfset thisStripGUID = Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") />
                                <cfparam name="form.rucval__#thisStripGUID#" default="0" />
                                <cfparam name="form.nucval__#thisStripGUID#" default="0" />

                                <cfif form[ "rucval__" & thisStripGUID] eq "">
                                    <cfset "form.rucval__#thisStripGUID#" = 0 />
                                </cfif>
                                <cfif form[ "nucval__" & thisStripGUID] eq "">
                                    <cfset "form.nucval__#thisStripGUID#" = 0 />
                                </cfif>

                                <cfset rucval = form[ "rucval__" & thisStripGUID] />

                                <cfset diffCalc = rucval - form["nucval__" & thisStripGUID] />

                                <cfset price = form["price_" & thisStripGUID] />

                                <cfset display_class = (rucval lt 0 or diffCalc lt 0 or price eq 0 ? "redDisplay" : "greenDisplay")>
                                <td class="numeric #display_class#" id="ruc__#thisStripGUID#">
                                    <cfif price eq 0>N/A<cfelse> #numberFormat( rucval, number_format_for_EA )# </cfif> #nbsp_filler#
                                    <span id="ruc__calc#thisStripGUID#" class="#display_class#"><cfif price eq 0>N/A<cfelse> #numberFormat( diffCalc, number_format_for_EA )# </cfif></span> #uom_filler#
                                </td>
                            </cfloop> <!---  query="qGetProducts" --->
                        </tr>
                    </cfif>   <!--- <cfif qGetData.Retailer_Unit_Cost eq 1> --->

                    <!------------------------------->
                    <!--- RETAILER UNIT COST W/LS --->
                    <!------------------------------->
                    <!--- Display Retailer Unit Cost if template setting is on --->
                    <cfif qGetData.Retailer_Unit_Cost eq 1>
                        <tr class="GridviewScrollItem" id="RetailerUnitCostWLs">
                            <td>Retailer Unit Cost W/LS</td>
                            <cfloop query="qGetProducts">

                                <cfset thisStripGUID = Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") />
                                <cfset rucLs = form[ "rucvalLS__" & thisStripGUID] />

                                <cfset diffCalc = rucLs - form["nucval__" & thisStripGUID] />
                                <cfset price = form["price_" & thisStripGUID] />
                                <cfset display_class = (rucLs lt 0 or diffCalc lt 0 or price eq 0 ? "redDisplay" : "greenDisplay")>
                                <td class="numeric #display_class#" id="rucls__#thisStripGUID#">
                                    <cfif price eq 0>N/A<cfelse> #numberFormat( rucLs, number_format_for_EA )# </cfif> #nbsp_filler#
                                    <span id="ruc__calcls#thisStripGUID#" class="#display_class#"><cfif price eq 0>N/A<cfelse> #numberFormat( diffCalc, number_format_for_EA )# </cfif></span> #uom_filler#
                                </td>
                            </cfloop> <!---  query="qGetProducts" --->
                        </tr>
                    </cfif>   <!--- <cfif qGetData.Retailer_Unit_Cost eq 1> --->

                    <!--------------------------->
                    <!--- EVERYDAY UNIT PRICE --->
                    <!--------------------------->
                    <tr class="GridviewScrollItem">
                        <td>
                            <cfset merch_label = qGetData.Merch_Unit_Price eq 1 ? ",merch unit prices" : "">
                            <a class="everyday"
                                title="Click to add everyday unit retail #merch_label#">
                                <i class="fa fa-plus-square"></i> Everyday Unit Retail
                            </a>
                        </td>
                        <cfloop query="qGetProducts">
                            <cfset thisStripGUID = Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") />
                            <cfset prodUOM = form[ "prodUom__" & thisStripGUID] />

                            <!--- TODO: Substitute the number 2 below with the real units per CS from the DB ---->
                            <cfset nUnits = form[ "bUnits_" & thisStripGUID]>

                            <td class="numeric">
                                <cfparam name="form.everydayprice__#Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" default="0" />
                                <cfset useLakebaseForqGetEveryDayPrice = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetunitpricedata")>
<cfif useLakebaseForqGetEveryDayPrice>
	<cftry>
		<cfset qGetEveryDayPrice = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetunitpricedata", {
				"group_id" = "eq.#qGetProducts.BSA_Foodservice_Items_Master_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetEveryDayPrice = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetEveryDayPrice>
<cfquery name="qGetEveryDayPrice" dbtype="query">
                                    SELECT 	*
                                    FROM	qGetUnitPriceData
                                    WHERE	Group_ID = '#qGetProducts.BSA_Foodservice_Items_Master_ID#'
                                </cfquery>
</cfif>
                                <cfset everydayprice = 0 />
                                <cfset everydaypriceUom = 5 />

                                <cfif 1>

                                    <cfif qGetEveryDayPrice.RecordCount and trim(qGetEveryDayPrice.Everyday_Unit_Price) neq "">
                                        <cfset everydayprice = qGetEveryDayPrice.Everyday_Unit_Price />
                                        <cfset everydaypriceUom = qGetEveryDayPrice.UOM />
                                    <cfelse>
                                        <cfset useLakebaseForqGetProfileEveryDayPrice = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qplannerprofileproducts")>
<cfif useLakebaseForqGetProfileEveryDayPrice>
	<cftry>
		<cfset qGetProfileEveryDayPrice = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qplannerprofileproducts", {
				"item_key" = "eq.#qGetProducts.BSA_Foodservice_Items_Master_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProfileEveryDayPrice = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProfileEveryDayPrice>
<cfquery name="qGetProfileEveryDayPrice" dbtype="query">
                                            SELECT 	*
                                            FROM	qPlannerProfileProducts
                                            WHERE	Item_Key = '#qGetProducts.BSA_Foodservice_Items_Master_ID#'
                                        </cfquery>
</cfif>
                                        <cfif trim(qGetProfileEveryDayPrice.EveryDay_Unit_Price) neq "">
                                            <cfset everydayprice = qGetProfileEveryDayPrice.EveryDay_Unit_Price />
                                            <cfset everydaypriceUom = qGetProfileEveryDayPrice.UOM />
                                        </cfif>
                                    </cfif>
                                    <!--- Convert if needed --->
                                    <cfif prodUOM eq 1 and everydaypriceUom eq 2> <!---- LB -> Units --->
                                        <cfset everydayprice = everydayprice * Net_Weight / nUnits />
                                    <cfelseif prodUOM eq 2 and everydaypriceUom eq 5> <!---- Units -> LB --->
                                        <cfset everydayprice = everydayprice * nUnits / Net_Weight />
                                    </cfif>
                                </cfif>

                                <cfset "form.everydayprice__#Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" = numberFormat(everydayprice, "_.__") />
                                $
                                <input
                                    type="text"
                                    class="autoselect everyday"
                                    name="everydayprice__#Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#"
                                    value="#form[ "everydayprice__" &  Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") ]#"
                                    <cfif not form.bFormIsValid>
                                        disabled
                                    </cfif>
                                >
                                <cfset edlpUom = prodUOM />
                                <cfif prodUOM eq 1>
                                    <cfset edlpUom = 5 />
                                </cfif>
                                <input
                                    type="hidden"
                                    name="everydayuom__#Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#"
                                    value="#edlpUom#">
                                #uom_filler#
                            </td>
                        </cfloop> <!---  query="qGetProducts" --->
                    </tr>

                    <!------------------------>
                    <!--- MERCH UNIT PRICE --->
                    <!------------------------>
                    <!--- Display Merch Unit Price if template setting is on --->
                    <cfif qGetData.Merch_Unit_Price eq 1>
                        <tr class="GridviewScrollItem" id="MerchUnitPrice">
                            <!--- <td>Merch Unit Price</td> --->
                            <td>
                                <a class="merch"
                                    title="Click to add everyday unit retail, merch unit prices">
                                    <i class="fa fa-plus-square"></i> Merch Unit Price
                                </a>
                            </td>

                            <cfloop query="qGetProducts">

                            <cfset thisStripGUID = Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") />

                            <cfset prodUOM = form[ "prodUom__" & thisStripGUID] />

                            <!--- TODO: Substitute the number 2 below with the real units per CS from the DB ---->
                            <cfset nUnits = form[ "bUnits_" & thisStripGUID]>

                                <td class="numeric">
                                    <cfparam name="form.merchprice__#Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" default="0" />
                                    <cfquery name="qGetMerchPrice" dbtype="query">
                                        SELECT 	*
                                        FROM	qGetUnitPriceData
                                        WHERE	Lower(Group_ID) = '#LCase(qGetProducts.BSA_Foodservice_Items_Master_ID)#'
                                    </cfquery>

                                    <cfif qGetMerchPrice.RecordCount>

                                        <cfset merchprice = qGetMerchPrice.Merchant_Price />
                                        <cfset merchUom = qGetMerchPrice.UOM />
                                        <!--- Convert if needed --->
                                        <cfif prodUOM eq 1 and merchUom eq 2> <!---- LB -> Units --->
                                            <cfset merchprice = merchprice * Net_Weight / nUnits />
                                        <cfelseif prodUOM eq 2 and merchUom eq 5> <!---- Units -> LB --->
                                            <cfset merchprice = merchprice * nUnits / Net_Weight />
                                        </cfif>

                                        <cfset "form.merchprice__#Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" = numberFormat(merchprice, "_.__") />
                                    </cfif>
                                    $
                                    <input
                                        type="text"
                                        name="merchprice__#Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#"
                                        value="#form[ "merchprice__" &  Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") ]#"
                                        class="merchp autoselect"
                                        <cfif not form.bFormIsValid>
                                            disabled
                                        </cfif>
                                    />
                                    #uom_filler#
                                </td>
                            </cfloop> <!---  query="qGetProducts" --->
                        </tr>
                    </cfif>  <!--- <cfif qGetData.Merch_Unit_Price eq 1> --->

                    <!----------------------->
                    <!--- RETAILER MARGIN --->
                    <!----------------------->
                    <!--- Display Retailer Margin if template setting is on --->
                    <cfif qGetData.Retailer_Margin eq 1>
                        <tr class="GridviewScrollItem" id="RetailerMarginProfit">
                            <td>Retailer Margin / Profit</td>
                            <cfloop query="qGetProducts">
                                <cfset thisStripGUID = Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") />
                                <cfparam name="form.rucval__#thisStripGUID#" default="0" />
                                <cfparam name="form.merchprice__#thisStripGUID#" default="0" />
                                <cfset ruc = form["rucval__" & thisStripGUID] />
                                <cfset nMerchantPrice = form["merchprice__" & thisStripGUID] />
                                <cfset price = form["price_" & thisStripGUID] />
                                <cfif nMerchantPrice eq 0>
                                    <cfset rm = 0 />
                                <cfelse>
                                    <cfset rm = 100 * ((nMerchantPrice - ruc ) / nMerchantPrice) />
                                </cfif>
                                <cfset rmp = (nMerchantPrice - ruc)  />

                                <cfset display_class = (rm lt 0 or price eq 0 ? "redDisplay" : "greenDisplay")>
                                <td class="numeric #display_class#" id="rm__#Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#">
                                    <input type="hidden" name="retailMargin_#thisStripGUID#" value="#rm#" />
                                    <input type="hidden" name="Planner_Expected_Margin" value="#gGetExpMargin.Planner_Expected_Margin#" />
                                    <cfif price eq 0>N/A<cfelse>#DecimalFormat(rm)#%</cfif> #nbsp_filler# <cfif price eq 0>N/A<cfelse>#DollarFormat(rmp)#</cfif> #uom_filler#
                                </td>
                            </cfloop> <!---  query="qGetProducts" --->
                        </tr>
                    </cfif>   <!--- qGetData.Retailer_Margin eq 1 --->
                <!--- </tbody> --->
            </table>

            <div id="minMaxLegend" class="displayHidden message">
                <span>&nbsp;red&nbsp;</span> = rate is above the maximum template setting
                &nbsp;&nbsp;&nbsp;&nbsp;
                <span style="background-color: yellow">&nbsp;yellow&nbsp;</span> = rate is below the minimum template setting
            </div>

            <div id="ezRateLegend" class="displayHidden message">
                <span>&nbsp;red&nbsp;</span> = rate is above the maximum template setting
            </div>
        </div>

        <div id="bot100">
            <div id="bot102"></div>
        </div>

        <cfif form.bCopy eq 1 or form.bRevise eq 1>
            <cfset form.programIdCopyRevise = form.programId />
            <cfset form.programId = 0 />
        </cfif>
        <INPUT TYPE="hidden"	NAME="Product_List" 			VALUE="#Form.Product_List#">
        <INPUT TYPE="hidden"	NAME="ExistingProductList" 		VALUE="#Form.Product_List#">
        <INPUT TYPE="hidden" 	NAME="templateId" 				VALUE="#Form.templateId#">
        <INPUT TYPE="hidden" 	NAME="lFixedCompIds" 			VALUE="#Form.lFixedCompIds#">
        <INPUT TYPE="hidden" 	NAME="lRebateCompIds" 			VALUE="#Form.lRebateCompIds#" />
        <INPUT TYPE="hidden" 	NAME="lLumpSumCompIds"			VALUE="#Form.lLumpSumCompIds#">

        <INPUT TYPE="hidden" 	NAME="strFixedData" 			VALUE="#form.strFixedData#">
        <INPUT TYPE="hidden" 	NAME="strRebateData" 			VALUE="#form.strRebateData#">
        <INPUT TYPE="hidden" 	NAME="strLumpSumData"			VALUE="#form.strLumpSumData#">

        <INPUT TYPE="hidden" 	NAME="bSave"					VALUE="#form.bSave#">

        <!--- please do not change the contract_main_id class below, component popup requires it --->
        <INPUT TYPE="hidden" 	NAME="programId"				VALUE="#Form.programId#"   class="contract_main_id">
        <input type="hidden"	name="plannerId"				value="#form.plannerId#" />
        <input type="hidden"	name="customerId"				value="#form.customerId#" />
        <input type="hidden"	name="Product_List_Type"		value="#form.Product_List_Type#" />
        <input type="hidden"	name="bFromCompPopUp"			value="#form.bFromCompPopUp#" />
        <input type="hidden"	name="bSaveVolume"				value="0" />
		<input type="hidden"	name="bLoadVolumeFromDB"		value="0" />

        <INPUT TYPE="hidden" 	NAME="bHasGroup"				VALUE="#form.bHasGroup#">
        <INPUT TYPE="hidden" 	NAME="bIsGroupItems"			VALUE="#form.bIsGroupItems#">

        <!--- Group hidden form variables --->
        <INPUT TYPE="hidden" 	NAME="Level_1"					VALUE="#form.Product_List#">
        <INPUT TYPE="hidden" 	NAME="GroupLevel_1"				VALUE="#form.Product_List_Type#">
        <INPUT TYPE="hidden" 	NAME="bFromGroupPopUp"			VALUE="0">
        <!---
        <INPUT TYPE="hidden" 	NAME="Product_Group_Level_ID"	VALUE="#Form.Product_Group_Level_ID#">
        <INPUT TYPE="hidden" 	NAME="Pricing_Level_ID"			VALUE="#Form.Pricing_Level_ID#">
        <INPUT TYPE="hidden" 	NAME="Product_Group_ID"			VALUE="#Form.Product_Group_ID#">
        --->
        <INPUT TYPE="hidden" 	NAME="bFormIsValid"					VALUE="#form.bFormIsValid#">
    <cfif application.util.query.get_setting("Planner_Program_Volume_UOM", 0) EQ "2">
        <INPUT TYPE="hidden" 	NAME="Contract_Quantity_UOM_IDX"	VALUE="2">
    <cfelse>
        <INPUT TYPE="hidden" 	NAME="Contract_Quantity_UOM_IDX"	VALUE="1">
    </cfif>
        <INPUT TYPE="hidden" 	NAME="Planner_Start_Date"			VALUE="#DateFormat(qGetPlannerData.Planner_Start_Date, CF_DATE_FORMAT)#">
        <INPUT TYPE="hidden" 	NAME="Planner_End_Date"				VALUE="#DateFormat(qGetPlannerData.Planner_End_Date, CF_DATE_FORMAT)#">
        <INPUT TYPE="hidden" 	NAME="bVolumeChange"				VALUE="0">
        <INPUT TYPE="hidden" 	NAME="plTemplatedefaultUOM"			VALUE="#form.plTemplatedefaultUOM#">
        <INPUT TYPE="hidden" 	NAME="plTemplateProddefaultUOM"		VALUE="#form.plTemplateProddefaultUOM#">
        <INPUT TYPE="hidden" 	NAME="bCopy"						VALUE="#form.bCopy#">
        <INPUT TYPE="hidden" 	NAME="bRevise"						VALUE="#form.bRevise#">
        <INPUT TYPE="hidden" 	NAME="programIdCopyRevise"			VALUE="#form.programIdCopyRevise#">
        <INPUT TYPE="hidden" 	NAME="parentPlannerID"				VALUE="#form.parentPlannerID#">
        <INPUT TYPE="hidden" 	NAME="bIsInDirect"					VALUE="#form.bIsInDirect#">
        <input type="hidden"	name="bFromCompPopUpEdit"			value="#form.bFromCompPopUpEdit#" />
        <input type="hidden"	name="Allow_Retro_Revision"			value="#form.Allow_Retro_Revision#" />
        <input type="hidden"	name="Allow_Retro_Revision_Span"	value="#form.Allow_Retro_Revision_Span#" />
        <input type="hidden"	name="isARevsion"	                value="#form.isARevsion#" />
        <input type="hidden"	name="EZButton_On"	                value="#form.EZButton_On#" />
        <input type="hidden"	name="EZ_Contract_Id"	            value="#form.EZ_Contract_Id#" />
        <cf_cryp type="en" key="#request.key#" string ="#form.programId#">
        <INPUT TYPE="hidden" 	NAME="cryptProgramId"				VALUE="#cryp.value#">
        <INPUT TYPE="hidden" 	NAME="runDupChecker"				VALUE="1">
        <INPUT TYPE="hidden" 	NAME="plTemplateProgramVolumeDefaultUOM" VALUE="#form.plTemplateProgramVolumeDefaultUOM#">
        <INPUT TYPE="hidden" 	NAME="prgTemplateDefaultUOM" VALUE="#form.prgTemplateDefaultUOM#">


        <cfset render_hidden_input()>
    </form>

    <!--- this form with dynamic populated hidden inputs is sent to program volume plan popup --->
    <form name="volume_plan_popup" action="/planners/create/program_volume_plan.cfm" method="post" onsubmit="popup2022_form(this, 'volume_plan_popup', 'LG', 'MD')">
        <input type="hidden" name="programid" value="#form.programid#">
        <input type="hidden" name="product_list" id="product_list">
        <input type="hidden" name="Product_List_Type" value="#form.Product_List_Type#" />
        <input type="hidden" name="delivery_start_date" id="delivery_start_date">
        <input type="hidden" name="delivery_end_date" id="delivery_end_date">
        <input type="hidden" name="action"    value="show">
        <input type="hidden" name="delivery_weeks_only"  value="1">
    </form>

    <cf_cryp type="en" key="#request.key#" string ="#form.programId#">

    <form action="/common_files/contracts/contract_cancel_action.cfm" method="post" name="CancelForm" id="CancelForm">
        <input type="hidden" name="Program_ID" value="#cryp.value#" >
        <input type="hidden" name="cancel_option" value="0" >
    </form>

    <form action="/planners/create/planner_program_approve.cfm" method="post" name="approvalForm" id="approvalForm" onsubmit="popup_form(this, 'approvalForm', 400, 400)">
        <input type="hidden" name="approval_method" value="5" >
        <input type="hidden" name="approved_by_user_id" value="#request.AccessStructure.user_id#" >
        <input type="hidden" name="program_id" value="#form.programId#" >
    </form>

    <!--- this form is submitted when users click on everyday price or merch unit price --->
    <form action="everyday_merch.cfm" method="post" name="everyday_merch" onsubmit="popup2022_form(this, 'everyday_merch', 'SM', 'MD')">
        <input type="hidden" name="programid" value="#form.programId#">
        <input type="hidden" name="product_list" value="#form.product_list#">
        <input type="hidden" name="merch_unit_price" value="#qGetData.Merch_Unit_Price#">
        <input type="hidden" name="parent_callback" value="refreshEverydayMerch">
        <!--- include hidden price elements for copy/paste everyday popup --->
        #price_elements.toList( ' ' )#
    </form>
</cfoutput>



<!--- wr 113798 - pull in our fixed version of grid_view_scroll.js file --->
<cfset include_files = [ 	"/script/javascript/gridviewscroll/0.9/gridviewscroll.min.js"
                            ,"/script/javascript/jquery.cfjs.min.js"
                            ,"/script/javascript/numeral.min.js"
                            ,"/script/javascript/date_functions.js"
                            ,"/script/javascript/jquery.noty.packaged.min.js"
                            ,"/script/javascript/loglevel/1.6.8/loglevel.min.js"
                            ,"/script/javascript/dayjs/1.8/dayjs.min.js"
                            ,"/script/javascript/numeric/jquery.numeric.min.js"
                            ,"/styles/font-awesome.min.css"
                        ]>

<cf_include files=#arrayToList(include_files)#>

<script>
    <cfif structKeyExists(request, "is_developer") and request.is_developer>
        log.enableAll();
    </cfif>

    <cfoutput>
    const JS_DATE_FORMAT  = "#uCase( CF_DATE_FORMAT )#";
    const MAX_DURATION = #(qProgramTemplate.recordCount eq 0 or qProgramTemplate.Max_Duration eq 0
                                ? 0
                                : qProgramTemplate.Max_Duration_Length)#;
    const LUMP_SUM_ALLOCATION_METHOD = '#(qProgramTemplate.recordCount ? qProgramTemplate.lump_sum_allocation_method.lcase() : "component")#';
    </cfoutput>

    var colors = { negative:"red", positive:"green" };
    var volume_plan_clicks = 0;

    <cfif trim(Form.Product_List) eq "">
        check();
    </cfif>

    jQuery("input.date")
        .datepicker({
            dateFormat: "mm/dd/yy",

            changeMonth: true,
            changeYear: true,
            minDate: "<cfoutput>#DateFormat(qGetPlannerData.Planner_Start_Date, CF_DATE_FORMAT)#</cfoutput>",
            maxDate: "<cfoutput>#DateFormat(qGetPlannerData.Planner_End_Date, CF_DATE_FORMAT)#</cfoutput>",
            onSelect: function( selected ) {
                var elem = jQuery(this).attr("name");
                if ( elem === "Perf_Start_Date" ){
                    jQuery("input[name=Perf_End_Date]").datepicker("option", "minDate", selected);
                }
                else if ( elem === "Delivery_Start_Date" )
                    jQuery("input[name=Delivery_End_Date]").datepicker("option", "minDate", selected);

                $(this).trigger("change");
            }
        });


    // Delivery start Date can be before planner start date
    jQuery("input[name=Delivery_Start_Date]").datepicker( "option", "minDate", null)

     <cfoutput>
        var plannerStartDate = new Date("#DateFormat(qGetPlannerData.Planner_Start_Date, CF_DATE_FORMAT)#");
        var plannerEndDate = new Date("#DateFormat(qGetPlannerData.Planner_End_Date, CF_DATE_FORMAT)#");
    </cfoutput>

    jQuery("input[name=Perf_Start_Date]").change(function(){
        $(this).val( CleanDate($(this).val()) );
            var objPt = jQuery("select[name=Planner_Perf_Types_ID]");
        var objPED = jQuery("input[name=Perf_End_Date]");
        var objDSD = jQuery("input[name=Delivery_Start_Date]");
        var objDED = jQuery("input[name=Delivery_End_Date]");
        var dur = $('option:selected', objPt).attr('Duration');
        var dsd = $('option:selected', objPt).attr('deliveryDaysStart');
        var ded = $('option:selected', objPt).attr('deliveryDaysEnd');
        var d = $(this).val();

        if(d == ''){
            validate_date_fields_init(0, 0);
            return;
        }
        var d = new Date(d);
        var dPerEd = d;
        var dDelSd = d;
        var dDelEd = d;
        dur = parseInt(dur) -1;
        if(dur < 0) dur = 0;
        dsd = parseInt(dsd);
        ded = parseInt(ded);

        dPerEd = d.addDays(dur);
        dDelSd = dateAdd('d', d, -dsd);
        dDelEd = dateAdd('d', dPerEd, - ded);

        //  If text fields are already populated we will not overwrite, so use the text box values for validating
        if(objPED.val() != ""){
            dPerEd = objPED.val();
        }
        if(objDSD.val() != ""){
            dDelSd = objDSD.val();
        }
        if(objDED.val() != ""){
            dDelEd = objDED.val();
        }

        dPerEd = dayjs(dPerEd).format(JS_DATE_FORMAT);
        dDelSd = dayjs(dDelSd).format(JS_DATE_FORMAT);
        dDelEd = dayjs(dDelEd).format(JS_DATE_FORMAT);

        /////////////////////////////// Validate date values
        if(validate_date_fields(d, dPerEd, dDelSd, dDelEd, 1, 0).length){
            return;
        }

        if(objPED.val() == "" && $.IsDate(dPerEd)){
            objPED.val(dPerEd);
        }
        if(objDSD.val() == "" && $.IsDate(dDelSd)){
            objDSD.val(dDelSd);
        }

        if(objDED.val() == "" && $.IsDate(dDelEd)){
            objDED.val(dDelEd);
        }
        check();
    });

    jQuery("input[name=Perf_End_Date]").change(function(){
        $(this).val( CleanDate($(this).val()) );
        validate_date_fields_init(1, 0);
        check();
    });

    jQuery("input[name=Delivery_Start_Date]").change(function(){
        $(this).val( CleanDate($(this).val()) );
        validate_date_fields_init(1, 0);
        check();
    });

    jQuery("input[name=Delivery_End_Date]").change(function(){
        $(this).val( CleanDate($(this).val()) );
        validate_date_fields_init(1, 0);
        check();
    });

    let gridHeight = 590;
    let gridWidth  = Math.min(<cfoutput>#(qGetProducts.recordCount + 1)#</cfoutput> * 180, $(window).width() - 10);

    let my_grid = jQuery('table.pgrid').gridviewScroll({
            width: gridWidth,
            height: gridHeight,
              freezesize: 1,
            barsize: 18,
            railcolor: "#F0F0F0",
            barcolor: "#CDCDCD",
            barhovercolor: "#606060",
            bgcolor: "#F0F0F0",
            arrowsize: 30,
            varrowtopimg: "/Images/arrowvt.png",
            varrowbottomimg: "/Images/arrowvb.png",
            harrowleftimg: "/Images/arrowhl.png",
            harrowrightimg: "/Images/arrowhr.png",
            railsize: 16
        });

    ///////////////////////////////
    // program volume plan popup //
    ///////////////////////////////
    jQuery("i.volume").click(function(){
        var errors = []
            ,cnt = 0
            ,required = [ "Delivery_Start_Date", "Delivery_End_Date" ]
            ,messages = [ "Please enter a delivery start date.", "Please enter a delivery end date." ];

        // check on required fields
        for (cnt = 0; cnt <= required.length; cnt++) {
            var $obj = $("input[name=" + required[cnt] + "]");
            if ( $obj.val() == "" ) {
                errors.push( messages[cnt] );
                $obj.addClass( "attention" );
            }
            else {
                $obj.removeClass( "attention" );
            }
        };

        if ( $("input[name=programId]").val() == 0 ) {
            errors.push( "Please save the data first." );
        }

        if (errors.length) {
            dhtmlx.alert( { title: "Alert!", type: "confirm-warning", text: errors.join( "<br>" ) } );
            return false;
        }

        // gather products list
        var products = [];
        $("input.lfc").each(function(){
            var product_id = $.ListGetAt($(this).attr("name"), 2, '.');
            products.push( product_id );
        });
        // populate hidden inputs to send to popup
        $("input#product_list").val( products.join(",") );
        $("input#delivery_start_date").val( $("input[name=Delivery_Start_Date]").val() );
        $("input#delivery_end_date").val( $("input[name=Delivery_End_Date]").val() );
        volume_plan_clicks = volume_plan_clicks + 1;
        $("form[name=volume_plan_popup]").submit();
    });


    function validate_date_fields_init(bDisplayNoty, bValidateBlank) {
        return validate_date_fields(
            $("input[name=Perf_Start_Date]").val(),
            $("input[name=Perf_End_Date]").val(),
            $("input[name=Delivery_Start_Date]").val(),
            $("input[name=Delivery_End_Date]").val(),
            bDisplayNoty,
            bValidateBlank,
            $("input[name=isARevsion]").val(),
            $("input[name=Allow_Retro_Revision]").val(),
            $("input[name=Allow_Retro_Revision_Span]").val()
            );
    }

    function validate_date_fields(perfStartDate, perfEndDate, delStartDate, delEndDate, bDisplayNoty, bValidateBlank, bIsARevision, bAllowRetroRevision, retroRevisionSpan) {
        var errors = [],
            bNotyNeeded = 0,
            dPerfStartDate = Date.parse(perfStartDate),
            dPerfEndDate = Date.parse(perfEndDate),
            dDelStartDate = Date.parse(delStartDate),
            dDelEndDate = Date.parse(delEndDate);
            dDateToday = new Date();
            dDateToday = new Date(dDateToday.getFullYear(), dDateToday.getMonth(),dDateToday.getDate());
        <cfoutput>
        var plannerStartDate = new Date("#DateFormat(qGetPlannerData.Planner_Start_Date, CF_DATE_FORMAT)#");
        var plannerEndDate = new Date("#DateFormat(qGetPlannerData.Planner_End_Date, CF_DATE_FORMAT)#");
        var notyText = "<cfoutput>#Application.PlannerLabel#</cfoutput> dates (#DateFormat(qGetPlannerData.Planner_Start_Date, CF_DATE_FORMAT)# - #DateFormat(qGetPlannerData.Planner_End_Date, CF_DATE_FORMAT)#)";
        let earliest_date;
        /* determine the earliest date for start dates based on template setting */
        <cfif val( qProgramTemplate.Max_Duration_Length )>
            earliest_date = new Date( "#dateFormat( dateAdd( 'd', val( qProgramTemplate.Max_Duration_Length ) * -1, now() ), CF_DATE_FORMAT )#" );
        <cfelse>
            earliest_date = new Date( "#dateFormat( dateAdd( 'd', -9999, now() ), CF_DATE_FORMAT )#" );
        </cfif>
        </cfoutput>

        ////////////////////////////////// Perf start Date
        if(perfStartDate == "" && bValidateBlank){
            $("input[name=Perf_Start_Date]").addClass( "attention" );
            errors.push('Please enter a Perf start date.');
        }
        else if(dPerfStartDate < plannerStartDate || dPerfStartDate > plannerEndDate){
            $("input[name=Perf_Start_Date]").addClass( "attention" );
            errors.push('Perf start date must be within <cfoutput>#Application.PlannerLabel#</cfoutput> dates.');
            notyText = notyText + " <br> Perf start (" + dayjs(perfStartDate).format(JS_DATE_FORMAT) + ") not within plan dates";
            bNotyNeeded = 1;
        }
        else if ( dPerfStartDate < earliest_date ) {
            errors.push( "Performance start date cannot be earlier than " + dayjs( earliest_date ).format( JS_DATE_FORMAT ) );
        }
        else {
             $("input[name=Perf_Start_Date]").removeClass( "attention" );
        }

        ////////////////////////////////// Perf end Date
        if(perfEndDate == "" && bValidateBlank){
            $("input[name=Perf_End_Date]").addClass( "attention" );
            errors.push('Please enter a Perf end date.');
        }
        else if(dPerfEndDate < plannerStartDate || dPerfEndDate > plannerEndDate){
            $("input[name=Perf_End_Date]").addClass( "attention" );
            errors.push('Perf end date must be within <cfoutput>#Application.PlannerLabel#</cfoutput> dates.');
            notyText = notyText + " <br> Perf end (" + dayjs(perfEndDate).format(JS_DATE_FORMAT) + ") not within plan dates";
            bNotyNeeded = 1;
        }
        else if(dPerfEndDate < dPerfStartDate){
            $("input[name=Perf_End_Date]").addClass( "attention" );
            errors.push('Perf end date must be after start date.');
            notyText = notyText + " <br> Perf end date must be after start date";
            bNotyNeeded = 1;
        }
        else {
             $("input[name=Perf_End_Date]").removeClass( "attention" );
        }

        ////////////////////////////////// Delivery start Date
        if(delStartDate == "" && bValidateBlank){
            $("input[name=Delivery_Start_Date]").addClass( "attention" );
            errors.push('Please enter a Delivery start date.');
        }
        else if(dDelStartDate > plannerEndDate){
            $("input[name=Delivery_Start_Date]").addClass( "attention" );
            errors.push('Delivery start date must be before <cfoutput>#Application.PlannerLabel#</cfoutput> end date.');
            notyText = notyText + " <br> Delivery start (" + dayjs(delStartDate).format(JS_DATE_FORMAT) + ") not within plan end date";
            bNotyNeeded = 1;
        }
        else if(bIsARevision == 1){
            if(bAllowRetroRevision == 0 && dDelStartDate < dDateToday){
                $("input[name=Delivery_Start_Date]").addClass( "attention" );
                errors.push('Delivery start date cannot be in the past.');
                notyText = notyText + " <br> Delivery start (" + dayjs(delStartDate).format(JS_DATE_FORMAT) + ") is in the past";
                bNotyNeeded = 1;
            }
            else{
                differenceInDays=days_between(new Date(delStartDate),dDateToday)
                if(retroRevisionSpan > 0 && retroRevisionSpan != "NaN" && differenceInDays > retroRevisionSpan){
                    $("input[name=Delivery_Start_Date]").addClass( "attention" );
                    errors.push('Delivery start date cannot be more than ' + retroRevisionSpan + ' day(s) in the past.');
                    notyText = notyText + " <br> Delivery start (" + dayjs(delStartDate).format(JS_DATE_FORMAT) + ") cannot be more than " + retroRevisionSpan + " day(s) in the past.";
                    bNotyNeeded = 1;
                }

            }
        }
        else if ( dDelStartDate < earliest_date ) {
            errors.push( "Delivery start date cannot be earlier than " + dayjs( earliest_date ).format( JS_DATE_FORMAT ) );
        }
        else {
             $("input[name=Delivery_Start_Date]").removeClass( "attention" );
        }

        ////////////////////////////////// Delivery end Date
        if(delEndDate == "" && bValidateBlank){
            $("input[name=Delivery_End_Date]").addClass( "attention" );
            errors.push('Please enter a Delivery end date.');
        }
        else if(dDelEndDate < plannerStartDate || dDelEndDate > plannerEndDate){
            $("input[name=Delivery_End_Date]").addClass( "attention" );
            errors.push('Delivery end date must be within <cfoutput>#Application.PlannerLabel#</cfoutput> dates.');
            notyText = notyText + " <br> Delivery end (" + dayjs(delEndDate).format(JS_DATE_FORMAT) + ") not within plan dates";
            bNotyNeeded = 1;
        }
         else if(dDelEndDate < dDelStartDate){
            $("input[name=Delivery_End_Date]").addClass( "attention" );
            errors.push('Delivery end date must be after start date.');
            notyText = notyText + " <br> Delivery end date must be after start date.";
            bNotyNeeded = 1;
        }
        else {
             $("input[name=Delivery_End_Date]").removeClass( "attention" );
        }

        if ( MAX_DURATION > 0 ) {
            differenceInDays = days_between(new Date(delStartDate), new Date(dDelEndDate));
            if ( differenceInDays > MAX_DURATION ) {
                let duration_error = 'The length of the program cannot be more than ' + MAX_DURATION + ' days.';
                errors.push( duration_error );
                notyText = notyText + " <br> " + duration_error;
                bNotyNeeded = 1;
            }
        }

        if(bDisplayNoty && bNotyNeeded){
        noty({
            text: notyText,
            layout: "topCenter",
            type: 'success',
            closeWith: ['click', 'button'],
            killer: true });
        }
        else {
            $.noty.closeAll();
        }

        notifyDeliveryDateChange(delStartDate, delEndDate);

        return errors;
    }


    function notifyDeliveryDateChange(delStartDate, delEndDate) {

        <cfif form.programId neq 0 and form.bIsInDirect eq 0>
        var bNotyNeeded = 0;
        var bVolumeChange = $("input[name=bVolumeChange]").val();
        if(bVolumeChange == 0){// If volume was edited then we will set volume plan = user edited volume
            <cfoutput>
            var origDelivStart = new Date("#DateFormat(qGetData.Delivery_Start_Date, CF_DATE_FORMAT)#");
            var origDelivEnd = new Date("#DateFormat(qGetData.Delivery_End_Date, CF_DATE_FORMAT)#");
            var notyText = "Delivery dates have changed <br><br> Original: (#DateFormat(qGetData.Delivery_Start_Date, CF_DATE_FORMAT)# - #DateFormat(qGetData.Delivery_End_Date, CF_DATE_FORMAT)#)";
            </cfoutput>

            if((delStartDate != "" && new Date(delStartDate).getTime() != origDelivStart.getTime())
               || (delEndDate != "" && new Date(delEndDate).getTime() != origDelivEnd.getTime())){
                notyText = notyText + " <br> New: (" + dayjs(delStartDate).format(JS_DATE_FORMAT) + " - " + dayjs(delEndDate).format(JS_DATE_FORMAT) + ")";
                bNotyNeeded = 1;

                notyText = notyText + "<br><br>The volume will be updated on save. <br>Please review the volume."
            }

            if(bNotyNeeded){
                noty({
                    text: notyText,
                    layout: "topCenter",
                    type: 'warning',
                    closeWith: ['click', 'button'],
                    });

            }
        } // if(!bVolumeChange)
        </cfif>
        return true;
    }
    function duplicateProgramExists(){
        let allow_duplicate_programs = jQuery("select[name=Planner_Perf_Types_ID] option:selected").attr("allow_duplicate_programs");
        // 86658 - duplicate programs are allowed in selected performance type
        if (allow_duplicate_programs === "1") {
        }
        else {
        ///////////////////// Find if there are other programs in this planner same per type, with overlapping dates and same products
        <cfif form.Product_List neq "">
        var dupProgramList = [],
            iPgmLen = 0,
            colMap = [],
            sMessage = "",
            maxDisplay = 5;

        $.ajax({ url: "/mvc/Models/Planner/PlannerProgramManager.cfc"
                ,type: "post"
                ,timeout:60000
                ,data: { method: "checkDuplicateProgram"
                        ,plannerId:'<cfoutput>#form.plannerId#</cfoutput>'
                        ,contractNumber:'<cfoutput>#form.Contract_Number#</cfoutput>'
                        ,perfTypeId: jQuery("select[name=Planner_Perf_Types_ID]").val()
                        ,startDate: $("input[name=Perf_Start_Date]").val()
                        ,endDate: $("input[name=Perf_End_Date]").val()
                        ,productList: '<cfoutput>#form.Product_List#</cfoutput>'
                        ,delStartDate: $("input[name=Delivery_Start_Date]").val()
                        ,delEndDate: $("input[name=Delivery_End_Date]").val()
                        }

                ,dataType: "json"
                ,async: false
                ,success: function(r) {
                    dupProgramList = r;
                }
                ,error: function(XMLHttpRequest, textStatus, errorThrown) {
                    alert("Status: " + textStatus); alert("Error: " + errorThrown);
                }

        });

        iPgmLen = dupProgramList.DATA.length;

        if(iPgmLen){
            /////// Display program list

            //first - find my columns
            for(var i = 0; i < dupProgramList.COLUMNS.length; i++) {
                colMap[dupProgramList.COLUMNS[i]] = i;
            }

            sMessage = "Found duplicate <cfoutput>#Application.PlannerPrgLabel#</cfoutput>"
                            + (dupProgramList.DATA.length > 1 ? "s" : '')
                            + "\n (same product, same performance type, overlapping time period)\n";

            for(var i = 0; i < iPgmLen && i < maxDisplay; i++) {
                sMessage    += "\n"
                            + dupProgramList.DATA[i][colMap["CONTRACT_NUMBER"]] + ": "
                            + dupProgramList.DATA[i][colMap["CONTRACT_TITLE"]] + " ("
                            + dupProgramList.DATA[i][colMap["CONTRACT_START_DATE"]] + "-"
                            + dupProgramList.DATA[i][colMap["CONTRACT_END_DATE"]] + ")";

                if(i == (maxDisplay-1) && dupProgramList.DATA.length > maxDisplay){
                    sMessage    += "\n(more)....";
                }
            }

            alert(sMessage);

            return 1;

        }
        </cfif>
        }
    }
    //duplicate checker function. Logic to checker if any duplicate programs exist based on program template duplicate settings
    function programDupChecker(action){

        var id = $("input[name=cryptProgramId]").val();
        var bRun = $("input[name=runDupChecker]").val();
        var iPgmList = 0;
        var dupProgramList = [];
        //return if duplicate checker has already been run
        if(bRun == 0){
            return 0;
        }

        $.ajax({ url: "/mvc/Models/Planner/PlannerProgramManager.cfc"
                    ,type: "post"
                    ,timeout:60000
                    ,data: { method: "checkDuplicateProgramBasedOnTemplate"
                            ,plannerId:'<cfoutput>#form.plannerId#</cfoutput>'
                            ,programId: $("input[name=programId]").val()
                            }

                    ,dataType: "json"
                    ,async: false
                    ,success: function(r) {
                        dupProgramList = r;
                    }
            });

            iPgmList = dupProgramList;

            if(iPgmList != 0){
                NewWindow('/common_files/contracts/duplicate_check.cfm?CID=' + id + '&Mode=showDup&bFromPlannerRFAApprove=1&anyStatus=0&plannerId=<cfoutput>#form.plannerId#</cfoutput>&plannerAction=' + action  + '','Duplicate_Check','870','720','Yes','No');
                return 1;
            }
            return 0;

    }

    function validate_form() {
        try{
            var errors = []
                ,cnt = 0
                ,required = [ "Contract_Title"]
                ,messages = [ "Please enter a title."]
                ,perStartDate = $("input[name=Perf_Start_Date]").val()
                ,perEndDate = $("input[name=Perf_End_Date]").val()
                ,delStartDate = $("input[name=Delivery_Start_Date]").val()
                ,delEndDate = $("input[name=Delivery_End_Date]").val()
                ,prgId = $("input[name=programId]").val()
                ,planPerfStartDate = $("input[name=Planner_Start_Date]").val()
                ,planPerfEndDate = $("input[name=Planner_End_Date]").val()
                ,somFix = $( "input[name^='fixed_rate_']" )
                ,somReb = $( "input[name^='rebate_rate_']" )
                ,add_message;
            var somLump;

            if ( LUMP_SUM_ALLOCATION_METHOD === "component" ) {
                somLump = $( "input[name^='lump_sum_component_amount_']" );
            }
            else {
                somLump = $( "input[name^='lump_sum_rate_']" );
            }

            /////////////////////////////// Validate date values
            errors = validate_date_fields_init(0, 1);

            add_message = 1;
            for (cnt = 0; cnt <= required.length; cnt++) {
                var $obj = $("input[name=" + required[cnt] + "]");
                if ( $obj.val() == "" ) {
                    if (add_message) errors.push( messages[cnt] );
                    add_message = 0;
                    $obj.addClass( "attention" );
                }
                else {
                    $obj.removeClass( "attention" );
                }
            };

            add_message = 1;
            somFix.each(function (){
                var s = $(this).attr("name");
                $(this).removeClass( "attention" );
                if  ( parseFloat($(this).val()) != numeral($(this).val()) ){
                    if (add_message) errors.push( "Please enter a valid rate" );
                    add_message = 0;
                    $(this).addClass( "attention" );
                }
            });

            add_message = 1;
            somReb.each(function (){
                var s = $(this).attr("name");
                $(this).removeClass( "attention" );
                if  ( parseFloat($(this).val()) != numeral($(this).val()) ){
                    if (add_message) errors.push( "Please enter a valid rate" );
                    add_message = 0;
                    $(this).addClass( "attention" );
                }
            });

            add_message = 1;
            somLump.each(function (){
                var s = $(this).attr("name");
                $(this).removeClass( "attention" );
                if  ( cast_to_decimal($(this).val()) != numeral($(this).val()) ){
                    if (add_message) errors.push( "Please enter a valid value for <cfoutput>#plannerLabels.lump_sum_singular#</cfoutput>" );
                    add_message = 0;
                    $(this).addClass( "attention" );
                }
            });

            add_message = 1;
            $("input.lfc").each(function(){
                var thisVal = $(this).val().replace(/,/g, '');

                $(this).removeClass( "attention" );
                if(prgId != 0 && (thisVal == 0 || thisVal == "" || parseFloat(thisVal) != numeral(thisVal))){
                    if (add_message) errors.push('Please enter a valid volume');
                    add_message = 0;
                    $(this).addClass( "attention" );
                }
            });

            <cfif application.util.query.get_setting( "Require_Everyday_Unit_Retail", 0 ) eq '1'>
                {
                    /* define an error count variable - invisible outside this block */
                    let invalids = 0;

                    $( "input.everyday" ).each( function() {
                        let thisVal = $( this ).val();

                        if ( prgId != 0 && ( thisVal == 0 || thisVal == "" || parseFloat( thisVal ) != numeral( thisVal ) ) ) {
                            /* everyday unit retail is invalid */
                            invalids ++;
                            $( this ).addClass( "attention" );
                        }
                        else {
                            /* good everyday unit retail */
                            $( this ).removeClass( "attention" );
                        }
                    } ) ;

                    /* found at least one invalid everyday unit retail */
                    if ( invalids ) {
                        errors.push( "Please enter a valid everyday unit retail." );
                    }
                }
            </cfif>

            <cfif qGetData.Merch_Unit_Price eq 1>
                add_message = 1;
                $("input.merchp").each(function(){
                    var thisVal = $(this).val();

                    $(this).removeClass( "attention" );
                    if(prgId != 0 && (thisVal == 0 || thisVal == "" || parseFloat(thisVal) != numeral(thisVal))){
                        if (add_message) errors.push('Please enter a valid merch unit price');
                        add_message = 0;
                        $(this).addClass( "attention" );
                    }
                });
            </cfif>

            add_message = 1;
            $("input.rebate_scan").each(function(){
                var thisVal = $(this).valueAsNumber();

                $(this).removeClass( "attention" );
                if(thisVal == 0){
                    if (add_message) errors.push('Please enter a valid percentage');
                    add_message = 0;
                    $(this).addClass( "attention" );
                }
            });

            if (errors.length) {
                dhtmlx.alert( { title: "Alert!", type: "alert-warning", text: errors.join( "<br>" ) } );
                return false;
            }

            if ( duplicateProgramExists() ) {
                return false;
            }


            if ( rates_are_invalid() ) {
                return false;
            }

            if (check_min_max(1)) {
                return false;
            }

            // volume plan popup was clicked refresh volume plan parent page accordingly
            if ( volume_plan_clicks > 0 ) {
                // volume plan parent page has no changes, set green light to refresh
                if ($("input[dirty='1']", window.opener.document).length == 0) {
                    var refresh = 1;
                }
                else {
                    // volume plan parent page has unsaved changes, ask users if they want to refresh
                    var refresh = confirm( "There are unsaved changes on the volume plan page.\n\n"
                                            + "Click OK to ignore those changes and refresh\nthe volume plan page with new data.\n\n"
                                            + "Click Cancel to keep the volume plan as is." );
                }
                <cfif ! url.fromProgramSearch>
                // green light to refresh the parent page
                if ( refresh ) {
                    $("form[name=topnav]", window.opener.document).submit();
                }
            </cfif>
            }

            show_loader();
            $("input[name=bFormIsValid]").val(1);
            MyForm.bSave.value = 1;
            MyForm.submit();

            }
        catch(err){
            alert(err.message);
        }
    };


    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~ look for invalid/zero rates, warn with a message ~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    function rates_are_invalid() {
        let zero_rate_counter     = 0;
        let found_invalid_rates   = false;
        let value                 = 0;
        let not_greater_than_zero = 0;


        $( "input.discountRate[type=text]" ).each(function() {
            $(this).removeClass( "attention" );

            value = $(this).val();
            not_greater_than_zero = true;

            // is it a number?
            if ( !isNaN(parseFloat(value)) && isFinite(value) ) {
                // is it greater than zero?
                not_greater_than_zero = ( parseFloat(value) <= 0 ) ? true : false;
            }

            if ( not_greater_than_zero ) {
                zero_rate_counter++;
                $(this).addClass( "attention" );
            }
        });

        if ( zero_rate_counter ) {
            found_invalid_rates = !confirm( "Highlighted rates have zero value.\n\nClick Cancel to make changes or OK to accept them." );
        }

        return found_invalid_rates;
    }

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~ look for rates that are not within min/max rates, warn with a message ~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    function check_min_max(bDisplayMessage) {
        let min_max_errors   	= 0,
            return_min_max		= false;

        var 	somFix = $( "input[name^='fixed_rate_']" )
                ,somReb = $( "input[name^='rebate_rate_']" )
                ,somLump = $( "input[name^='lump_sum_component_amount_']" );

        somFix.each(function (){
            min_max_errors = min_max_errors + check_min_max_input($(this), 1);

        });

        somReb.each(function (){
            min_max_errors = min_max_errors + check_min_max_input($(this), 2);

        });

        somLump.each(function (){
            min_max_errors = min_max_errors + check_min_max_input($(this), 3);

        });

        if (min_max_errors && bDisplayMessage) {
            return_min_max = !confirm("Fields highlighted in yellow are below the minimum value. Fields highlighted in red are above the maximum value. Press ok to continue anyway or cancel to fix the entries.");
        }

        return return_min_max;
    }

    function check_min_max_input(txtObj, discountTypeId) {
        var s = txtObj.attr("name");
        var uomObjName = txtObj.attr("uomObjName");
        var uom = $("select[name=" + uomObjName + "]").val();
        var caseCount = txtObj.attr("caseCount");
        var sleevesPerCase = txtObj.attr("sleevesPerCase");
        var maxVal = 0, minVal = 0;
        var rateValue = cast_to_decimal(txtObj.val());
        var iError = 0;
        var Max_Case = 0,
            Max_Pound = 0,
            Max_Percent = 0,
            Min_Case = 0,
            Min_Pound = 0,
            Min_Percent = 0;

        <cfoutput>
        if(discountTypeId == 1){
            Max_Case = #Val(oGetTemplateData.Max_Fixed_Case)#;
            Max_Pound = #Val(oGetTemplateData.Max_Fixed_Pound)#;
            Max_Percent = 0;
            Min_Case = #Val(oGetTemplateData.Min_Fixed_Case)#;
            Min_Pound = #Val(oGetTemplateData.Min_Fixed_Pound)#;
            Min_Percent = 0;
        }
        else if(discountTypeId == 2){
            Max_Case = #Val(oGetTemplateData.Max_Rebate_Case)#;
            Max_Pound = #Val(oGetTemplateData.Max_Rebate_Pound)#;
            Max_Percent = #Val(oGetTemplateData.Max_Rebate_Percent)#;
            Min_Case = #Val(oGetTemplateData.Min_Rebate_Case)#;
            Min_Pound = #Val(oGetTemplateData.Min_Rebate_Pound)#;
            Min_Percent = #Val(oGetTemplateData.Min_Rebate_Percent)#;
        }
        else if(discountTypeId == 3){
            Max_Case = #Val(oGetTemplateData.Max_Lump_Sum)#;
            Max_Pound = 0;
            Max_Percent = 0;
            Min_Case = #Val(oGetTemplateData.Min_Lump_Sum)#;
            Min_Pound = 0;
            Min_Percent = 0;

            uom = 1;
        }
        </cfoutput>

        txtObj.removeClass( "aboveMax");
        txtObj.removeClass( "belowMin");

        if  (rateValue == numeral(txtObj.val()) ){ // valid numeric value

            // get values based on uom
            if(uom == 1){
                maxVal = Max_Case;
                minVal = Min_Case;
            }
            else if(uom == 2){
                maxVal = Max_Pound;
                minVal = Min_Pound;
            }
            else if(uom == 3){
                maxVal = Max_Percent;
                minVal = Min_Percent;
            }
            else if (uom == 5){ // eaches -> CS
                rateValue = rateValue * parseFloat(caseCount);
                maxVal = Max_Case;
                minVal = Min_Case;
            }
            else if (uom == 6){ // CWT -> LB
                rateValue = rateValue / 100.00;
                maxVal = Max_Pound;
                minVal = Min_Pound;
            }
            else if (uom == 7){ // sleeves -> CS
                rateValue = rateValue * parseFloat(sleevesPerCase);
                maxVal = Max_Case;
                minVal = Min_Case;
            }

            // compare
            if(maxVal != 0 && rateValue > maxVal){
                txtObj.addClass( "aboveMax");
                iError++;
            }
            else if(minVal != 0 && rateValue < minVal){
                txtObj.addClass( "belowMin");
                iError++;
            }
        }
        if(iError){
            $("#minMaxLegend").removeClass( "displayHidden");
        }
        return iError;
    }


    $( "input.merchp" ).change(function() {
        var guid = $.ListGetAt($(this).attr("name"), 2, '__');
        var mup = $(this).val();
        mup = parseFloat(mup);
        var	rucval = 0;
        var	valRetailerMarginPer = 0;
        var	valRetailerMargin = 0;

        //var som = $( "input[name$=" + guid + "]" );
        var rucval = parseFloat($("input[name=rucval__" + guid + "]").val());
        var price = $("input[name=price_" + guid + "]").val();

        valRetailerMarginPer = (mup == 0 ? 0 : 100 * ((mup - rucval) / mup)) ;
        valRetailerMarginPerDisp = numeral(valRetailerMarginPer).format('0,0.00') + '%';

        valRetailerMargin = mup - rucval;
        valRetailerMargin = numeral(valRetailerMargin).format('($0,0.00)');

        if(price == 0){
            valRetailerMarginPerDisp = "N/A";
            valRetailerMargin = "N/A";
        }

        $("#rm__" + guid).html(valRetailerMarginPerDisp + <cfoutput>"#nbsp_filler#"</cfoutput> + valRetailerMargin + <cfoutput>"#uom_filler#"</cfoutput>).css("color", (valRetailerMarginPer < 0 || price == 0 ? colors.negative : colors.positive));

    });

    function discountChange(guid, discType, compProdGuid){
        // ngt
        if ( LUMP_SUM_ALLOCATION_METHOD === "component" ) {
            if ( $("input.lump_sum_component").length ) {
                calculate_all_lump_sum();
            }
        }
        var price = $("input[name=price_" + guid + "]").val();
        price = parseFloat(price);
        var	valDiscount = 0;
        var	retailUnitCost = 0;
        var	valRetailerMarginPer = 0;
        var	valRetailerMargin = 0;
        var	LumpSum = 0;
        var	retailUnitCostLs = 0;
        var	retailUnitCostDiff = 0;
        var	retailUnitCostLsDiff = 0;
        var	hiddenSetVal2 = 0;
        var	hiddenSetVal3 = 0;
        var	hiddenSetVal7 = 0;
        var preFormatsetVal8 = 0;
        var preFormatsetVal9 = 0;
        var nAllSum = 0;
        var calc = 0;
        var somReb = $( "input[name^='rebate_rate_']" );
        var mup = 0;
        <cfif qGetData.Merch_Unit_Price eq 1>
            mup = $("input[name=merchprice__" + guid + "]").val();
        </cfif>
        var somLump = $( "input[name^='lump_sum_rate_']" );
        var nuc = $("input[name=nucval__" + guid + "]").val();
        var nUnit = $("input[name=bUnits_" + guid + "]").val();
        var nEDLP = $("input[name=edlp__" + guid + "]").val();
        var guid2 = guid.replace(/_/g, "-");
        var nVol = $("input[name='vol." + guid2 + "']").val();
        var somFix = $( "input[name^='fixed_rate_']" );
        var defaultUom = $("input[name=prodUom__" + guid + "]").val();
        var thisDiscountVal, thisDiscountUom, thisDiscountUnitSpanName, thisDiscountInUnit;
        var netWeight = $("input[name=netWeight_" + guid + "]").val();
        var caseCount = $("input[name=case_count_" + guid + "]").val();
        var sleevesPerCase = $("input[name=Sleeves_per_case_" + guid + "]").val();


        /*******************************************************************/
        if(discType == 1) {
            thisDiscountVal = $("input[name=fixed_rate_" + compProdGuid + "]").val();
            thisDiscountUom = $("select[name=fixed_uom_" + compProdGuid + "]").val();
            thisDiscountUnitSpanName = "fixedPriceUnit_" + compProdGuid;
        }
        else if(discType == 2) {
            thisDiscountVal = $("input[name=rebate_rate_" + compProdGuid + "]").val();
            thisDiscountUom = $("select[name=rebate_uom_" + compProdGuid + "]").val();
            thisDiscountUnitSpanName = "rebateUnit_" + compProdGuid;
        }

        if(discType == 1 || discType == 2) {
            if(thisDiscountUom == 1 || thisDiscountUom == 7){ // show EA
                if(thisDiscountUom == 1){
                    thisDiscountInUnit = thisDiscountVal / nUnit;
                }
                else{
                    thisDiscountInUnit = (thisDiscountVal * sleevesPerCase) / nUnit;
                }
                $("#" + thisDiscountUnitSpanName).html( numeral(thisDiscountInUnit).format('$0,0.00') + ' <span class="uom">EA</span>');
            }
            else{ // show nothing
                $("#" + thisDiscountUnitSpanName).html(' ');
            }
        }

        somFix.each(function (){
            var s = $(this).attr("name");
            var n = s.search(guid);
            var rate = 0;
            if (n > -1){
                var uomObjName = $(this).attr("uomObjName");
                var uom = $("select[name=" + uomObjName + "]").val();

                if(uom != defaultUom){
                    if (defaultUom == 1){
                        rate = parseFloat($(this).val()) * parseFloat(netWeight);
                    }
                    else{
                        rate = parseFloat($(this).val()) / parseFloat(netWeight);
                    }
                }
                else{
                    rate = parseFloat($(this).val());
                }
                valDiscount = valDiscount + (price - parseFloat(rate));

                // check if rate is within min/max
                check_min_max_input($(this), 1);
            }
        });


        somReb.each(function (){
            var s = $(this).attr("name");
            var n = s.search(guid);
            var rate = 0;

            if (n > -1){
                var uomObjName = $(this).attr("uomObjName");
                var uom = $("select[name=" + uomObjName + "]").val();

                //percent
                if(uom == 3){
                    rate = parseFloat($(this).val()) * 0.01 * price;
                }
                else if(uom == 5){ //eaches
                    if(defaultUom == 1){
                        rate = parseFloat($(this).val()) * parseFloat(caseCount);
                    }
                    else{
                        rate = (parseFloat($(this).val()) * parseFloat(caseCount)) / parseFloat(netWeight);
                    }

                }
                else if(uom == 6){ //CWT
                    if(defaultUom == 1){
                        rate = ((parseFloat($(this).val()) / 100.00)) * parseFloat(netWeight);
                    }
                    else{
                        rate = (parseFloat($(this).val()) / 100.00);
                    }

                }
                else if(uom == 7){ //sleeves
                    if(defaultUom == 1){
                        rate = parseFloat($(this).val()) * parseFloat(sleevesPerCase);
                    }
                    else{
                        rate = (parseFloat($(this).val()) * sleevesPerCase) / parseFloat(netWeight);
                    }

                }
                else if(uom != defaultUom){
                    if (defaultUom == 1){
                        rate = parseFloat($(this).val()) * parseFloat(netWeight);
                    }
                    else{
                        rate = parseFloat($(this).val()) / parseFloat(netWeight);
                    }
                }
                else{
                    rate = parseFloat($(this).val());
                }
                valDiscount = valDiscount + parseFloat(rate);

                // check if rate is within min/max
                check_min_max_input($(this), 2);
                // check ez rate
                check_ez_rate_input($(this), 2);
            }
        });

        // sum up all individual product lump sum amounts
        somLump.each(function (){
            var s = $(this).attr("name");
            var n = s.search(guid);
            if (n > -1){
                LumpSum = LumpSum + parseFloat($(this).val());
            }
        });


        nAllSum = parseFloat(valDiscount) + (parseFloat(LumpSum) / parseFloat(nVol));
        calc = parseFloat(price) - parseFloat(nAllSum) - parseFloat(nEDLP);
        retailUnitCostLs = parseFloat(calc);
        retailUnitCost = (price - valDiscount - parseFloat(nEDLP));


        if(defaultUom == 1){
            retailUnitCost = retailUnitCost / nUnit;
            retailUnitCostLs = retailUnitCostLs / nUnit;
        }

        valRetailerMarginPer = 0;
        if(retailUnitCost != 0 && mup != 0){
            valRetailerMarginPer = 100.00 * ((mup - retailUnitCost) / mup);
        }
        valRetailerMargin = mup - retailUnitCost;
        retailUnitCostDiff = retailUnitCost - nuc;
        retailUnitCostLsDiff = retailUnitCostLs - nuc;

        hiddenSetVal3 = retailUnitCost;
        hiddenSetVal7 = retailUnitCostLs;
        retailUnitCost = numeral(retailUnitCost).format('($0,0.00)');

        valRetailerMarginPerDisp = numeral(valRetailerMarginPer).format('0,0.00') + '%';
        valRetailerMargin = numeral(valRetailerMargin).format('($0,0.00)');
        retailUnitCostLs = numeral(retailUnitCostLs).format('($0,0.00)');

        preFormatsetVal8 = retailUnitCostDiff;
        preFormatsetVal9 = retailUnitCostLsDiff;

        retailUnitCostDiff = numeral(retailUnitCostDiff).format('($0,0.00)');
        retailUnitCostLsDiff = numeral(retailUnitCostLsDiff).format('($0,0.00)');

        if(price == 0){
            retailUnitCostDiff = "N/A";
            retailUnitCostLsDiff = "N/A";
            preFormatsetVal8 = "N/A";
            preFormatsetVal9 = "N/A";
            retailUnitCost = "N/A";
            retailUnitCostLs = "N/A";
            valRetailerMarginPerDisp = "N/A";
            valRetailerMargin = "N/A";
        }

        $("#ruc__" + guid).html(retailUnitCost
                                    + <cfoutput>"#nbsp_filler#"</cfoutput>
                                    + '<span id="ruc__calc'
                                    + guid + '">'
                                    + retailUnitCostDiff
                                    + <cfoutput>'</span>#uom_filler#'</cfoutput>)
                          .css("color", (hiddenSetVal3 < 0 || price == 0 ? colors.negative : colors.positive));
        $("#rucls__" + guid).html(retailUnitCostLs
                                    + <cfoutput>"#nbsp_filler#"</cfoutput>
                                    + '<span id="ruc__calcls' + guid + '">'
                                    + retailUnitCostLsDiff
                                    + <cfoutput>'</span>#uom_filler#'</cfoutput>)
                            .css("color", (hiddenSetVal7 < 0 || price == 0 ? colors.negative : colors.positive));
        $("#rm__" + guid).html(valRetailerMarginPerDisp
                                    + <cfoutput>"#nbsp_filler#"</cfoutput>
                                    + valRetailerMargin
                                    + <cfoutput>"#uom_filler#"</cfoutput>)
                         .css("color", (valRetailerMarginPer < 0 || price == 0 ? colors.negative : colors.positive));
        $("input[name=rucval__" + guid + "]").val(hiddenSetVal3);
        $("input[name=discountSum_" + guid + "]").val(valDiscount);

        $("#ruc__calc"   + guid).css("color", (preFormatsetVal8 < 0 || price == 0 ? colors.negative : colors.positive));
        $("#ruc__calcls" + guid).css("color", (preFormatsetVal9 < 0 || price == 0 ? colors.negative : colors.positive));
    }


    $("#top100 input").focusout(function() {
        check();
     });

    function check(){

        var errors = []
            ,cnt = 0
            ,required = [ "Contract_Title", "Perf_Start_Date", "Perf_End_Date", "Delivery_Start_Date", "Delivery_End_Date" ]
            ,objIsValid =  $("input[name=bFormIsValid]")
            ,prgId = $("input[name=programId]").val()
            ,bIsRevision = $("input[name=bRevise]").val()
            ,bCopy = $("input[name=bCopy]").val();

        for (cnt = 0; cnt <= required.length; cnt++) {

            var $obj = $("input[name=" + required[cnt] + "]");
            if ( $obj.val() == "" ) {
                errors.push(cnt);
            }
        }

        if(errors.length == 0 && (bIsRevision == 1 || bCopy == 1 || prgId != 0)){
            objIsValid.val(1);
            $("#mid100 input:not([readonly])").prop("disabled", false);
            $("#mid100").show(500);
        }
        else{
            $("#mid100 input").prop("disabled", true);
        }
    }

    $("input.lfc").change(function(){

        var product_id = $.ListGetAt($(this).attr("name"), 2, '.');
        var obj = $("input[name=volChange" + product_id + "]");
        obj.val(1);
        $("input[name=bVolumeChange]").val(1);
        $("input.discountRate").trigger("change");

    });

    <cfif request.program_in_edit_mode eq false>
        $("input[type=text], select, textarea, a, i.volume, button.button").attr("disabled", true).addClass("disabled");


    </cfif>

    <cfif form.approved eq 1 and form.bCopy eq 0 and form.bRevise eq 0>
        $("#top100 a, #top100 input[type=text], #top100 select, #top100 textarea, #top100 i.volume").removeAttr("onclick title").addClass("disabled");
        $("#mid100 input[type=text], #mid100 select, #mid100 textarea, #mid100 i.volume").removeAttr("onclick title").addClass("disabled");
        $("#mid100 a").removeAttr("onclick").addClass("disabled");
        $( "i.ls_recalc" ).hide();
    </cfif>

    <cfif form.programId eq 0>
        $("#mid100 a, #mid100 input[type=text], #mid100 select, #mid100 textarea, #mid100 i.volume").removeAttr("onclick title").addClass("disabled");
        $("a.discount").removeAttr("onclick title").addClass("disabled");
        $("a.addLink").removeAttr("onclick title").addClass("disabled");
        $("i[name=view_documents]").removeAttr("onclick title");
		$('#btnProd').prop('disabled', true);
		$('#btnProdGroups').prop('disabled', true);
    </cfif>

    $("span.pgroup").click(function(){
        popupInCenter( "/planners/create/planner_group_items.cfm"
                        + "?Group_ID=" + $(this).attr("item_key")
                        <cfoutput>
                        + "&Group_Level_ID=#form.product_list_type#"
                        + "&program_id=#form.programId#"
                        </cfoutput>
                        ,"planner_group_items", 715, 600);
    });

    $("input.date")
        .change(function(e) {
            let input = $(this).val();
            if (input !== '') {
                if (dayjs(input, JS_DATE_FORMAT, true).isValid()) {
                    // format date input to avoid any confusions
                    $(this).val( dayjs(input).format( JS_DATE_FORMAT ) );
                }
                else {
                    e.stopPropagation();
                    alert(input + " is not a valid date, please change it.");
                    // reset invalid date to blank to re-trigger the change event
                    // otherwise invalid date would skip validation
                    $(this).val('').focus();
                }
            }
        })
        .blur(function() {
            $(this).val( CleanDate($(this).val()) );
        });

    refresh_parent = function(){
        // refresh parent window by submitting the topnav form
        var parent_form = window.opener.document.forms["topnav"];
        if (parent_form) {
            parent_form.submit();
        }
    }
    <cfif refresh_parent_form AND  ! url.fromProgramSearch>
        refresh_parent();
    </cfif>



    <!--- RETAIL-359  Copy from program menu changes: Display inactive items that were removed --->
    <cfif url.removedInactive eq 1>
        NewWindow('/Common_Files/contracts/view_contract_inactive_products.cfm?ContractID=<cfoutput>#form.programId#</cfoutput>','name','650','400','Yes', 'Yes');
        //window.location.href = "/Planners/Create/planner_program_create.cfm?programId=<cfoutput>#form.programId#</cfoutput>&plannerID=<cfoutput>#form.plannerId#</cfoutput>&customerID=<cfoutput>#form.customerId#</cfoutput>&templateId=<cfoutput>#form.templateId#</cfoutput>&bInit=1";
    </cfif>

    $('input.rebate_scan').numeric({ negative: false, decimal: false });



    function cast_to_decimal( str ) {
        let result = 0;
        if (typeof str === "string") {
            // remove commas then convert to integer
            result = parseFloat( str.replace(/,/g, "") );
            if ( isNaN( result ) ) {
                result = 0;
            }
        }
        return result;
    }

    function cast_to_integer( str ) {
        let result = 0;
        if (typeof str === "string") {
            // remove commas then convert to integer
            result = parseInt( str.replace(/,/g, "") );
            if ( isNaN( result ) ) {
                result = 0;
            }
        }
        return result;
    }

    function round_amount( amt ) {
        return Math.round( amt * 100 ) / 100;
    }

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~ calculate total volume in all products ~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    function get_volume_total() {
        let total_volume = 0;
        let uomAlloc        = <cfoutput>#val(form.lsAllocationUOM)#</cfoutput>;

        $("input[name^='vol.']").each(function() {
            let amount = cast_to_integer( $(this).val() );
            //perform lump sum allocation based on planner template or program template default uom setting
            if(uomAlloc == 2) {
                if ( $(this).attr("uomId").toLowerCase() === "1" ) {
                    /* convert amount from CS to LB */
                    amount = numCalc( amount * $(this).attr("net_weight") );
                }
            }
            else {
                if ( $(this).attr("uomId").toLowerCase() === "2" ) {
                    /* convert amount from LB to CS */
                    amount = numCalc( amount / $(this).attr("net_weight") );
                }
            }
            // sum it up
            total_volume = numCalc( total_volume + amount );
        });

        return total_volume;
    }

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~ calculate lump sum amounts for one lump sum component (on same row) ~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    function calculate_single_lump_sum( lump_sum_id ) {
        // ngt
        if ( LUMP_SUM_ALLOCATION_METHOD === "component" ) {
            let total_volume = get_volume_total();

            $("input.lump_sum_component[lump_sum=" + lump_sum_id + "]").each(function() {
                let lump_sum_total = cast_to_decimal( $(this).val() );
                let rate_per_uom   = numCalc( lump_sum_total / total_volume );
                let running_total  = 0;
                let counter        = 0;
                let elements       = $("input[lump_sum=" + lump_sum_id + "][name^='lump_sum_rate_']");
                let uomAlloc        = <cfoutput>#val(form.lsAllocationUOM)#</cfoutput>;

                elements.each(function() {
                    counter++;
                    let product_sql_guid = $(this).attr("guid").replace(/_/g, "-");
                    let product_element  = $("input[name='vol." + product_sql_guid + "']");
                    let product_volume   = cast_to_integer( product_element.val() );

                    if(uomAlloc == 2) {
                        if ( product_element.attr("uomId").toLowerCase() === "1" ) {
                            /* convert product volume from CS to LB */
                            product_volume = numCalc( product_volume * product_element.attr("net_weight") );
                        }
                    }
                    else {
                        if ( product_element.attr("uomId").toLowerCase() === "2" ) {
                            /* convert product volume from LB to CS */
                            product_volume = numCalc( product_volume / product_element.attr("net_weight") );
                        }

                    }
                    let new_product_lump_sum = counter == elements.length
                                                    ? round_amount( numCalc( lump_sum_total - running_total ) )        // last element, get the remaining
                                                    : round_amount( numCalc( rate_per_uom * product_volume ) );

                    $(this).val( numeral(new_product_lump_sum).format('(0,0.00)') );
                    running_total = numCalc( running_total + new_product_lump_sum );
                });
            });
        }
    }

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~ calculate lump sum amounts for all lump sum components ~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    function calculate_all_lump_sum() {
        $("input.lump_sum_component").each(function(){
            calculate_single_lump_sum( $(this).attr("lump_sum") );
        });
    }

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~ recalculate lump sum amounts when lump sum component amount is changed ~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    if ( LUMP_SUM_ALLOCATION_METHOD === "component" ) {
        $("input.lump_sum_component")
            // .numeric({ negative: false, decimal: true })
            .change(function(){
                calculate_single_lump_sum( $(this).attr("lump_sum") );
                check_min_max_input($(this), 3);
        });

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~ recalculate lump sum amounts when product volume is changed ~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        $("input[name^='vol.']")
            .numeric({ negative: false, decimal: false })
            .change(function(){ calculate_all_lump_sum(); });

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~ allocate lump sum amounts to products ~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        calculate_all_lump_sum();
    }


    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Check min/max ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    check_min_max(0);
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~ ex rate checks ~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    function check_ez_rate(bDisplayMessage) {
        let ez_rate_errors   	= 0
        var 	somReb = $( "input[name^='rebate_rate_']" )
                ,somLump = $( "input[name^='lump_sum_component_amount_']" );


        somReb.each(function (){
            ez_rate_errors = ez_rate_errors + check_ez_rate_input($(this), 2);
        });
        somLump.each(function (){
            ez_rate_errors = ez_rate_errors + check_ez_rate_input($(this), 3);
        });
        if (ez_rate_errors && bDisplayMessage) {
            ez_rate_errors = !confirm("Fields highlighted in red are above the maximum template setting. Press ok to continue anyway or cancel to fix the entries.");
        }
        if(ez_rate_errors != 0){
            $("#ezRateLegend").removeClass( "displayHidden");
        }
    }
    function check_ez_rate_input(txtObj, discountTypeId) {
        var s = txtObj.attr("name");
        var uomObjName = txtObj.attr("uomObjName");
        var uomObj = $("select[name=" + uomObjName + "]");
        var uom = $("select[name=" + uomObjName + "]").val();
        var caseCount = txtObj.attr("caseCount");
        var sleevesPerCase = txtObj.attr("sleevesPerCase");
        var netWeight = txtObj.attr("netWeight");
        var rateValue = cast_to_decimal(txtObj.val());
        var iError = 0;
        var ezRateValue = txtObj.attr("ezRate");
        var ezRateUOM = txtObj.attr("ezRateUOM");
        var guid = txtObj.attr("guid");
        var price = $("input[name=price_" + guid + "]").val();
        price = parseFloat(price);
        var defaultUom = $("input[name=prodUom__" + guid + "]").val();
        <cfoutput>
        var ezButtonDefaultShowItemRates = #Val(qGetData.EzButton_Default_Show_Item_Rates)#;
        var discountRebateMaxRateOn = #Val(qGetData.Discount_Rebate_Max_Rate_On)#;
        </cfoutput>
        //if ezRateValue is not equal to 0 then we know it has an ez rate
        if(discountTypeId == 2 && ezRateValue != 0){
            //Convert the rate
            if(uom != ezRateUOM){
                //convert price into EZ UOM if default UOM is defferent from EZ UOM
                priceEZUOM = convertToUOMJS(defaultUom,price,price,netWeight,caseCount,sleevesPerCase,ezRateUOM);
                //convert rebate rate into EZ UOM
                rateValue = convertToUOMJS(uom,rateValue,priceEZUOM,netWeight, caseCount,sleevesPerCase,ezRateUOM);
            }
            //if Rebates are absolute amounts or Rebates are max amounts (rates are displayed) and the rate is 0 then just set the rate to the ez rate.
            if(discountRebateMaxRateOn == 0 || (ezButtonDefaultShowItemRates == 1 && rateValue <= 0)){
                txtObj.val(ezRateValue);
                //Disable if Rebates are absolute amounts
                if(discountRebateMaxRateOn == 0){
                    txtObj.addClass("disabled");
                }
            }
            else{
                //if Rebates are max amounts (rates are displayed) or Rebates are max amounts (rates are hidden) and the rate entered is greater than the ez rate then flag the input in red
                if(ezRateValue < rateValue){
                    txtObj.addClass( "aboveEzRate");
                    iError++;
                }
                else{
                    txtObj.removeClass( "aboveEzRate");
                }
            }
        }
        else if(discountTypeId == 3){
        }
        return iError;
    }

    check_ez_rate(0);


    function convertToUOMJS(currentUom,currentRate,price,netWeight,nUnits,sleevesPerCase,returnUOM){

        var returnValue = 0;

        // percent
        if (currentUom == 3) {
            returnValue = currentRate * 0.01 * price;
        }
        // eaches
        else if (currentUom == 5) {
            // Eaches --> CS
            if ( returnUOM == 1 )
                returnValue = currentRate * nUnits;
            //  Eaches --> CS --> LB
            else
                returnValue = (currentRate * nUnits) / netWeight;
        }
        // cwt
        else if (currentUom == 6) {
            // CWT --> LB --> CS
            if ( returnUOM == 1 )
                returnValue = (currentRate / 100.00) * netWeight;
            // CWT --> LB
            else
                returnValue = (currentRate / 100.00);
        }
        // sleeves
        else if (currentUom == 7) {
            // Sleeve --> CS
            if ( returnUOM == 1 )
                returnValue = currentRate * sleevesPerCase;
            // Sleeve --> CS --> LB
            else
                returnValue = (currentRate * sleevesPerCase) / netWeight;
        }
        else if ( currentUom != returnUOM ) {
            if ( returnUOM == 1 )
                returnValue = currentRate * netWeight;
            else
                returnValue = currentRate / netWeight;
        }
        else {
            returnValue = currentRate;
        }

        return returnValue;
    }

	/* D113201: Planner Program - Alternate Customer / Anand Rao / 11-Feb-2022 */

	function fnSelectAltCust(option)
	{
		window.open('planner_alternate_customers.cfm?bEdit=' + option + '&plannerId=<cfoutput>#form.plannerId#</cfoutput>&CID=<cfoutput>#form.CID#</cfoutput>&programID=<cfoutput>#form.programID#</cfoutput>','CustomerSelection','width=900,height=900,scrollbars=1');
	}

</script>

<cfset url.removedInactive = 0 />

<cfscript>
    function getVolumeFactor( required product_sql_guid ) {
        local.qNetWeightUOM = queryExecute( " SELECT  Inventory_UM, Net_Weight
                                                FROM  qGetProducts
                                               WHERE  BSA_Foodservice_Items_Master_ID = '#arguments.product_sql_guid#'
                                            "
                                            , {}
                                            , { dbtype:"query" } );
        return ( local.qNetWeightUOM.Inventory_UM is "CS"
                    ? local.qNetWeightUOM.Net_weight
                    : 1 );
    }
</cfscript>

<cffunction name="rate_format" output="false" hint="Returns the display format to apply to case, pounds, percentages and others.">
    <cfargument name="uom" required="false" default="2">

    <!--- (1) cs = 2 decimals, (2) lb = 4 decimals, (3) % = 3 decimals - otherwise use a default format --->
    <cfset local.rate_formats = [ "_.__", "_.____", "_.___" ]>

    <cftry>
        <!--- for the regular uoms (case, pound and percentage)--->
        <cfreturn local.rate_formats[ arguments.uom ]>

        <cfcatch type="any">
            <!--- for other unexpected uoms --->
            <cfreturn "_.__">
        </cfcatch>
    </cftry>

</cffunction>

<cffunction name="convertDiscountToUOM" output="false" hint="Returns the discount converted to a specific uom">
    <cfargument name="discountType" type="numeric">
    <cfargument name="discountUom" type="numeric">
    <cfargument name="discountRate" type="numeric">
    <cfargument name="returnUom" type="numeric">
    <cfargument name="price" type="numeric">
    <cfargument name="netWeight" type="numeric">
    <cfargument name="nUnits" type="numeric">
    <cfargument name="sleevesPerCase" type="numeric">

    <cfscript>
        nUnits = arguments.nUnits;
        prodUOM = returnUom;
        returnValue = 0;

        if(arguments.discountType == 1){
            thisFixedUom = arguments.discountUom;
            thisFixedRate = arguments.discountRate;
            thisFixedSumRate = thisFixedRate;
            if (thisFixedUom neq prodUOM ) {
                // eaches
                if(thisFixedUom == 5){
                    // Eaches --> CS
                    if ( prodUOM eq 1 )
                        thisFixedSumRate = thisFixedRate * nUnits;
                    //  Eaches --> CS --> LB
                    else
                        thisFixedSumRate = (thisFixedRate * nUnits) / arguments.netWeight;
                }
                        // CWT
                else if (thisFixedUom eq 6) {
                    // CWT --> LB --> CS
                    if ( prodUOM eq 1 )
                        thisFixedSumRate = (thisFixedRate / 100.00) * arguments.netWeight;
                    // CWT --> LB
                    else
                        thisFixedSumRate = (thisFixedRate / 100.00) ;
                }
                // sleeves
                else if (thisFixedUom eq 7) {
                    // Sleeve --> CS
                    if ( prodUOM eq 1 )
                        thisFixedSumRate = thisFixedRate * arguments.sleevesPerCase;
                    // Sleeve --> CS --> LB
                    else
                        thisFixedSumRate = (thisFixedRate * arguments.sleevesPerCase) / arguments.netWeight;
                }
                if(prodUOM == 1){		//convert from LB to CS
                    thisFixedSumRate = thisFixedRate * arguments.netWeight;
                }
                else {		//convert from CS to LB
                    thisFixedSumRate = thisFixedRate / arguments.netWeight;
                }
            }
            returnValue = arguments.price - thisFixedSumRate;
        }
        else if(arguments.discountType == 2){
            thisRebUom = arguments.discountUom;
            thisRebRate = arguments.discountRate;
            thisRebateSumRate = 0;

            // percent
            if (thisRebUom eq 3) {
                thisRebateSumRate = thisRebRate * 0.01 * arguments.price;
            }
            // eaches
            else if (thisRebUom eq 5) {
                // Eaches --> CS
                if ( prodUOM eq 1 )
                    thisRebateSumRate = thisRebRate * nUnits;
                //  Eaches --> CS --> LB
                else
                    thisRebateSumRate = (thisRebRate * nUnits) / arguments.netWeight;
            }
            // CWT
            else if (thisRebUom eq 6) {
                // CWT --> LB --> CS
                if ( prodUOM eq 1 )
                    thisRebateSumRate = (thisRebRate / 100.00) * arguments.netWeight;
                // CWT --> LB
                else
                    thisRebateSumRate = (thisRebRate / 100.00);
            }
            // sleeves
            else if (thisRebUom eq 7) {
                // Sleeve --> CS
                if ( prodUOM eq 1 )
                    thisRebateSumRate = thisRebRate * arguments.sleevesPerCase;
                // Sleeve --> CS --> LB
                else
                    thisRebateSumRate = (thisRebRate * arguments.sleevesPerCase) / arguments.netWeight;
            }
            else if ( thisRebUom neq prodUOM ) {
                if ( prodUOM eq 1 )
                    thisRebateSumRate = thisRebRate * arguments.netWeight;
                else
                    thisRebateSumRate = thisRebRate / arguments.netWeight;
            }
            else {
                thisRebateSumRate = thisRebRate;
            }
            returnValue = thisRebateSumRate;
        }

    </cfscript>

    <cfreturn returnValue />

</cffunction>


<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!---  gather hidden input into request variable   --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<cffunction name="save_hidden_input" output="false">
    <cfargument name="name" required="true">
    <cfargument name="value" required="true">

    <!--- create request variable to store hidden input --->
    <cfif not structKeyExists(request, "hidden_input")>
        <cfset request.hidden_input = []>
    </cfif>

    <cfset local.is_defined = false>
    <!--- verify if hidden input is already defined --->
    <cfloop array="#request.hidden_input#" item="local.hidden_element">
        <cfif local.hidden_element.name eq arguments.name>
            <cfset local.is_defined = true>
        </cfif>
    </cfloop>

    <cfif not local.is_defined>
        <!--- save hidden input to be used later --->
        <cfset request.hidden_input.append( {name:arguments.name, value:arguments.value } )>
    </cfif>
</cffunction>


<!--- ~~~~~~~~~~~~~~~~~~~~~ --->
<!---  render hidden input  --->
<!--- ~~~~~~~~~~~~~~~~~~~~~ --->
<cffunction name="render_hidden_input" output="true">

    <cfif structKeyExists(request, "hidden_input")>
        <cfloop array="#request.hidden_input#" item="local.hidden_element">
            <input type="hidden" name="#local.hidden_element.name#" value="#local.hidden_element.value#">
        </cfloop>
    </cfif>

</cffunction>

<!--- ~~~~~~~~~~~~~~~~~~~~~ --->
<!---  get ez rate  --->
<!--- ~~~~~~~~~~~~~~~~~~~~~ --->
<cffunction name="getEZRateData" output="false" hint="Returns EZ Rate if one exists">
    <cfargument name="itemGUID" type="string">
    <cfargument name="discountType" type="numeric">
    <cfset returnValue = 0 />
    <cfif arguments.discountType eq 2>
        <cfquery name="qGetEZRate" dbtype="query">
            SELECT 	*
            FROM	qGetEZButtonDefaultRebateRates
            WHERE	BSA_Foodservice_Items_Master_ID = '#arguments.itemGUID#'
        </cfquery>
        <cfset returnValue = qGetEZRate />
    </cfif>
    <cfreturn returnValue />
</cffunction>

<cfinclude template="\common_files\popup2022.cfm">

<script>
    $( "a.everyday, a.merch" ).click( function() {
        if ( document.MyForm.Product_List.value == "" ) {
            alert( "Please add a product or a group first." );
        }
        else {
            $( "form[ name=everyday_merch ]" ).submit();
        }
    } );

    function refreshEverydayMerch() {
        $.ajax( {  url: "/mvc/Models/Planner/PlannerProgramManager.cfc"

                  ,data: { method: "getEverydayMerch", program_Id: $("input[name=programId]").val() }

                  ,error: function( XMLHttpRequest, textStatus, errorThrown ) { error_handler( arguments ); }

                  ,success: function( result ) { refreshEverydayMerch_2( JSON.parse( result ) ); }
        } );
    }

    function refreshEverydayMerch_2( json ) {
        // Sample json input array
        // [
        //     {
        //         "GROUP_ID": "0312E4D6-C844-41C9-808E-8556A36EFA9E",
        //         "MERCHANT_PRICE": 0.250,
        //         "MERCHANT_QUANTITY": 1,
        //         "UOM": 5,
        //         "EVERYDAY_UNIT_PRICE": 0.250,
        //         "EVERYDAY_LOW_PRICE": null,
        //         "FREE_CASES": null
        //     }
        // ]
        try {
            for ( var i = 0; i < json.length; i++ ) {
                // convert db guid into CF friendly guid
                var group_id = json[i].GROUP_ID.replace(/-/g, "_");

                $( "input[name=everydayprice__" + group_id + "]" ).val( numeral( json[i].EVERYDAY_UNIT_PRICE ).format( '(0,0.00)' ) );
                $( "input[name=merchprice__"    + group_id + "]" ).val( numeral( json[i].MERCHANT_PRICE ).format( '(0,0.00)' ) );
            }
        }
        catch ( error ) {
            console.log( error );
        }
    }

	/* 	113201	Planner Program - Alternate Customer / Anand Rao / 27-Feb-2022
		Disable/Enable the "select" button when the user checks the checkbox.
	*/
	$("#AltCustomers").click(function() {
        var checked_status = this.checked;
        if (checked_status == true) {

        $("#selAlt").removeAttr("disabled");
        } else {
            var confirmdelete = confirm("Unchecking will delete all the selected alternate customers on the next save. You won't be able to undo this change...");
            if (confirmdelete == true)
            {
                $("#selAlt").attr("disabled", "disabled");
            }
            else
            {
                $("#AltCustomers").attr("checked",true);
            }
        }
    });

    let current_operation = '';
    let numeric_elements  = [   "input.ls_prod:not(:disabled)"
                                ,"input.lfc:not(:disabled)"
                                ,"input.everyday:not(:disabled)"
                                ,"input.merchp:not(:disabled)"
                                ,"input.discountRate:not(:disabled)"
                                ,"input.lump_sum_component:not(:disabled)"
                            ];

    <cfif request.program_in_edit_mode>
        // ngt - lump sum allocation by component/product amount change event listener
        $( "input.ls_prod" ).change( function() {
            // skip recalculating ls total when reallocating is in progress
            if ( current_operation == '' ) {
                let total = 0;
                let ls_id = $( this ).attr( "lump_sum" );

                $( "input.ls_prod" ).each( function() {
                    if ( $( this ).attr( "lump_sum" ) === ls_id ) {
                        total += +$( this ).val();
                    }
                });

                // update both hidden total element and readonly/disabled total element - both have the same name
                $( "input[name=lump_sum_component_amount_" + ls_id + "]" ).each( function() {
                    $( this ).val( numeral( total ).format( '(0,0.00)' ) );
                } );
            }
        });

        // manage numeric editing ( i.e. filter out non-numeric keypresses )
        $( numeric_elements.join() ).numeric({ negative: false, decimal: true });

        // ngt - reallocate based on volume for lump sum allocation by component/product
        $( "i.ls_recalc" ).click( function() {
            current_operation  = "lump sum reallocating";
            let lump_sum_id    = $( this ).attr( "lump_sum" );
            let ls_elements    = $( "input.ls_prod[lump_sum=" + lump_sum_id + "]" );

            if ( ls_elements.length > 1 ) {
                let lump_sum_total = cast_to_decimal( $( "input[name=lump_sum_component_amount_" + lump_sum_id + "]" ).val() );
                let total_volume   = get_volume_total();
                let running_total  = 0;
                let counter        = 0;
                let rate_per_uom   = numCalc( lump_sum_total / total_volume );
                let uomAlloc        = <cfoutput>#val(form.lsAllocationUOM)#</cfoutput>;

                ls_elements.each( function() {
                    counter++;
                    let this_element     = $( this );
                    let product_sql_guid = this_element.attr( "guid" ).replace(/_/g, "-");
                    let product_element  = $( "input[name='vol." + product_sql_guid + "']" );
                    let product_volume   = cast_to_integer( product_element.val() );
                    //perform lump sum allocation based on planner template or program template default uom setting
                    if(uomAlloc == 2) {
                        if ( product_element.attr("uomId").toLowerCase() === "1" ) {
                            /* convert product volume from CS to LB */
                            product_volume = numCalc( product_volume * product_element.attr("net_weight") );
                        }
                    }
                    else {
                        if ( product_element.attr("uomId").toLowerCase() === "2" ) {
                            /* convert product volume from LB to CS */
                            product_volume = numCalc( product_volume / product_element.attr("net_weight") );
                        }

                    }
                    let new_product_lump_sum = ( counter == ls_elements.length
                                                    ? round_amount( numCalc( lump_sum_total - running_total ) )       // last element, get the remaining
                                                    : round_amount( numCalc( rate_per_uom * product_volume  ) ) );

                    let formatted_value = numeral( new_product_lump_sum ).format( '(0,0.00)' );

                    this_element.val( formatted_value );
                    running_total = numCalc( running_total + new_product_lump_sum );
                });
            }

            // reset current operation
            current_operation = "";
        });
    </cfif>
</script>

<cfinclude template="/common_files/dhx_message.cfm">

</cf_layout_planner_program>