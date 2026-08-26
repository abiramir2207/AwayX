<cfparam name="url.ComingFromPlanner" default="0">

<cfif  ! url.ComingFromPlanner>
	<cfinclude template="\developer\timeTracking.cfm" runOnce="true">
</cfif>

<!---
Document by: Ana Shankar
Duplicate check logic flow:
1. Get the list of programs that satisfy the Date, template and spending category.
2. Loop over the list from #1
	a. Check Operator (go to next program from #1 if the comparison fails)
	b. Check Distributor (go to next program from #1 if the comparison fails)
	c. Check Components (go to product check, if the comparison criteria is satified)<!--- Dev Note: Milan; D8549 --->
	d. Check Discount Type & products (go to next program from #1 if the comparison fails)
	e. Check Rate
3. Exit loop from #2 if find any (first instance) duplicate program
 --->
<cfparam name="DuplicateProgramIDList" default="">
<cfparam name="debug" default="0">
<cfparam name="url.anyStatus" default="0">
<cfparam name="url.plannerId" default="0">
<!--- Mark S :: 115090  performance fix --->
<cfparam name="lProgramList" default="">
<cfparam name="lDupCheckedList" default="">

	<cfparam name="duplicateprogram" default="">
	<cfparam name="PageName" default="Duplicate Program">
	<cfparam name="variables.dupeItems" default="" />
	<!--- break the system whenever encountering false, otherwise return true--->
	<!--- get the control setting for the duplicate program definition --->
	<!--- check for the check_program_duplicate bit first--->
	<!---- true, then retrieve the duplicate definition information --->

	<CFSET DuplicateProgramIDList = "">
	<cfset appSettings = application.appSettingsGet />
	<cfset ProgramManager = CreateObject("component","components.programs.Program") />
	<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
	<cfset qProgramInfo = ProgramManager.getProgramInfo(cryp.value) />
	<!---  	Mark S :: 115090
			CHECK LATEST TEMPLATE ALWAYS :: Otherwise turning it on and off has no affect until programs are revised. --->
	<cfset ContractControlID = templateManager.getLatestTemplateId(qProgramInfo.programtype_id)>
	<!--- <cfset ContractControlID = qProgramInfo.programtype_id> --->
	<cfset dupProgramManager = CreateObject("component","components.programs.duplicate_program.duplicateProgramManager").init(cryp.value,ContractControlID) />
	<cfscript>
		/*
			Mark S :: 115090  performance fix
				For planners this is called in a loop and usually for the same 1-2 templates.  Put the var in the request scope so we can use it on the next loop
				For non-planners this is an extra step, but it is just a memory pointer and only lives for the request
		*/
		/* 		 SET variables.dupTemplateManager		*/
    	if ( !StructKeyExists(request, "DuplicateTemplateManager#ContractControlID#")){
    		variables.dupTemplateManager = CreateObject("component","components.programs.template.DuplicateTemplateManager").init(ContractControlID,'#trim(PageName)#');
    		request["DuplicateTemplateManager#ContractControlID#"] = variables.dupTemplateManager;
    	}
    	else{
    		variables.dupTemplateManager = request["DuplicateTemplateManager#ContractControlID#"];
    	}
    	/* 		 SET variables.template		*/
    	if ( !StructKeyExists(request, "template#ContractControlID#")){
    		variables.template = templateManager.get(ContractControlID);
    		request["template#ContractControlID#"] = variables.template;
    	}
    	else{
    		variables.template = request["template#ContractControlID#"];
    	}
    </cfscript>
<!---
	 	<cfset dupTemplateManager = CreateObject("component","components.programs.template.DuplicateTemplateManager").init(ContractControlID,'#trim(PageName)#') />
		<cfset template = templateManager.get(ContractControlID)>
	--->

	<cfset allow_dup_programs = template.getDuplicate()>
	<cfset variables.Generic_Type = template.getGenericType()>
	<SCRIPT LANGUAGE="JavaScript">
		document.getElementById('Display_Message').innerHTML = 'Checking duplicate program(s)';
	</SCRIPT>

<cfif structKeyExists(request, "skip_cfflush") is "no">
    <cfflush>
</cfif>

 

	<cfif allow_dup_programs EQ 1>
		<!---TSF: Label 9997 - Added default value to handle for "product_radio_index" not being defined --->
		<cfparam name="product_radio_index" default="0" />
		<!--- retrieve definition setting --->
		<cfset getDefintion = dupTemplateManager.getDupProgramDefinition()>
 	
		<cfif getDefintion.recordCount GT 1>
			<cfloop query="getDefintion">
				<cfif item EQ 2>
					<cfset date_radio_index = Item_Radio_Index >
				</cfif>
				<cfif item EQ 5>
					<cfset is_product_checked = isChecked>
					<cfif is_product_checked EQ 1>
						<cfset product_radio_index = Item_Radio_Index>
					</cfif>
				</cfif>
				<cfif item EQ 6>
					<cfset is_rate_checked = isChecked>
				</cfif>
				<cfif item EQ 9>
					<cfset is_component_checked = isChecked>
				</cfif>
			</cfloop>
			<cfif date_radio_index EQ 1>
				<cfset CheckDates = dupProgramManager.GetExistingContractInfo(GetContractInfo.Contract_Start_Date, GetContractInfo.Contract_End_Date, cryp.value, product_radio_index, url.anyStatus, url.plannerId) />
			<cfelse>
				<cfset CheckDates = dupProgramManager.GetOverLappingDateContractInfo(GetContractInfo.Contract_Start_Date, GetContractInfo.Contract_End_Date, cryp.value, product_radio_index, url.anyStatus, url.plannerId) />
			</cfif>

			<cfif CheckDates.recordCount EQ 0>
				<cfset duplicateprogram = "false">
				<cfexit>
			</cfif>
            <cfset GetSelectedDefinition = dupTemplateManager.GetSelectedDefinition()>
			<CFLOOP query="CheckDates">
				<!--- 	IF  CheckDates.contract_main_id is in "already checked List" then skip to the next program since we know the answer to this already
						This is for Performance when we check the entire Planner			Mark S :: 115090 --->
				<cfif ListFindNoCase(lDupCheckedList,CheckDates.contract_main_id) NEQ 0 AND url.ComingFromPlanner EQ 1>
					<cfcontinue>
				</cfif>
				<cfset debug && application.util.io.debugLog( "<h1>Check Date Start</h1><br>" )>
				<cfset check_contract_main_id = CheckDates.contract_main_id>
				<cfset check_contract_number = CheckDates.contract_number>
				<cfset check_contract_title = CheckDates.contract_title>
				<cfset check_contract_creator = CheckDates.creator_id>
				<cfset duplicateprogram = "true">
				<cfset Discount_Types ="">
				<cfset debug && application.util.io.debugLog( "<cfoutput><h1>check_contract_main_id: #check_contract_main_id# - check_contract_number: #check_contract_number# - check_contract_title: #check_contract_title#</h1></cfoutput><br>" )>
				<!--- <cfset GetSelectedDefinition = dupTemplateManager.GetSelectedDefinition()> --->
                <CFLOOP query="GetSelectedDefinition">
				<cfswitch expression="#item#">
				<cfcase value="9">
					<cfif is_component_checked EQ 1>
						<cfset debug && application.util.io.debugLog( "<h1>component checking</h1><br>" )>
							<!--- get the discount types (Fixed,Rebate,Lumpsum, and Growth) --->
							<cfset qForAllDiscountTypes = dupProgramManager.GetDiscountTypes() />
							<!--- then check each rate based on the discount type --->
							<cfif qForAllDiscountTypes.recordCount GT 0>
								<cfloop query = "qForAllDiscountTypes">
									<cfswitch expression="#qForAllDiscountTypes.Product_Type_ID#">
										<cfcase value="1">
										<!---- fixed price --->
												<cfset debug && application.util.io.debugLog( "<h1>same component checking for fixed price</h1><br>" )>
												<cfset qFixedComponent = dupProgramManager.GetFixedPriceComponent(cryp.value, check_contract_main_id)>
												<cfif qFixedComponent.recordCount NEQ 0>
													<!--- This program has matching Fixed price components --->
													<cfset Discount_Types = ListAppend(Discount_Types,Product_Type_ID)>
												</cfif>
										</cfcase>
										<cfcase value = "2">
											<cfset debug && application.util.io.debugLog( "<h1>same component checking for rebate</h1><br>" )>
										<!--- Rebate ---><!--- waiting for group level --->
												<cfset qRebateComponent = dupProgramManager.GetRebateComponent(cryp.value, check_contract_main_id)>
												<cfif qRebateComponent.recordCount NEQ 0>
													<!--- This program has matching rebate components --->
													<cfset Discount_Types = ListAppend(Discount_Types,Product_Type_ID)>
												</cfif>
										</cfcase>
										<cfcase value="3">
											<cfset debug && application.util.io.debugLog( "<h1>same component checking for lump sum</h1><br>" )>
										<!--- lump sum --->
												<cfset qLumpSumComponent = dupProgramManager.GetLumpSumComponent(cryp.value, check_contract_main_id)>
												<cfif qLumpSumComponent.recordCount NEQ 0>
													<!--- This program has matching lumpsum components --->
														<cfset Discount_Types = ListAppend(Discount_Types,Product_Type_ID)>
												</cfif>
										</cfcase>
										<cfcase value="4"><!--- waiting for group level check --->
											<cfset debug && application.util.io.debugLog( "<h1>same component checking for growth</h1><br>" )>
										<!--- growth component --->
												<cfset qGrowthComponent = dupProgramManager.GetGrowthComponent(cryp.value, check_contract_main_id)>
												<cfif qGrowthComponent.recordCount NEQ 0>
													<!--- This program has matching growth components --->
														<cfset Discount_Types = ListAppend(Discount_Types,Product_Type_ID)>
												</cfif>
										</cfcase>
										<cfcase value="8">
											<cfset debug && application.util.io.debugLog( "<h1>same component checking for offInvoice</h1><br>" )>
										<!--- offInvoice component --->
												<cfset qOffInvoiceComponent = dupProgramManager.GetOffInvoicePriceComponent(cryp.value, check_contract_main_id)>
												<cfif qOffInvoiceComponent.recordCount NEQ 0>
													<!--- This program has matching offInvoice components --->
														<cfset Discount_Types = ListAppend(Discount_Types,Product_Type_ID)>
												</cfif>
										</cfcase>
									</cfswitch>
								</cfloop>
							</cfif>
						</cfif>
					</cfcase>
                    <cfcase value="5">
							<cfset debug && application.util.io.debugLog( "<h1>******* start checking products **********</h1><br>" )>
							<cfif is_product_checked EQ 1>
								<cfif product_radio_index EQ 1>
									<cfset debug && application.util.io.debugLog( "<h1>******* exact product checking **********</h1><br>" )>
									<!--- Matching components in all discount types --->
									<cfif Discount_Types neq "">
											<cfloop list="#Discount_Types#" index="DiscountType">
												<cfset getcurrentProducts = dupProgramManager.GetNotInProductInfo(cryp.value, check_contract_main_id, DiscountType)>
												<cfif getcurrentProducts.recordCount EQ 0>
												<!--- then check for the reverse order --->
												<cfset getcurrentProducts = dupProgramManager.GetNotInProductInfo(check_contract_main_id, cryp.value, DiscountType)>
													<cfif getcurrentProducts.recordCount EQ 0>
															<cfset duplicateprogram = "true">
															<cfbreak>
													<cfelse>
															<cfset duplicateprogram = "false">
															<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 100" )>
													</cfif>
												</cfif>
											</cfloop>
									<cfelse>
									<!--- No Matching component --->
												<cfset getcurrentProducts = dupProgramManager.GetNotInProductInfo(check_contract_main_id, cryp.value)>
									</cfif>
									<cfif getcurrentProducts.recordCount NEQ 0>
										<cfset duplicateprogram = "false">
										<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 110" )>
									</cfif>
								<cfelse>
									<cfset debug && application.util.io.debugLog( "<h1>******* at least product checking **********</h1><br>" )>
								<!--- Matching components in at least one discount type --->
									<cfif Discount_Types neq "">
											<cfloop list="#Discount_Types#" index="DiscountType">
												<cfset getcurrentProducts = dupProgramManager.GetInProductInfo(cryp.value, check_contract_main_id, DiscountType) >
															<cfif getcurrentProducts.recordCount NEQ 0>
																<cfset duplicateprogram = "true">
																<cfbreak>
															<cfelse>
																	<cfset duplicateprogram = "false">
																	<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 120" )>
															</cfif>
											</cfloop>
									<cfelse>
										<!--- No Matching component --->
												<cfset getcurrentProducts = dupProgramManager.GetInProductInfo(cryp.value, check_contract_main_id) >
									</cfif>
									<cfif getcurrentProducts.recordCount EQ 0>
													<cfset duplicateprogram = "false">
													<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 130" )>
									</cfif>
									<!---
									<cfif is_group EQ 1 and getcurrentProducts.recordCount NEQ 0>
										<cfset getcurrentProducts = dupProgramManager.GetInProductGroupInfo(cryp.value, check_contract_main_id) >
									</cfif> --->
								</cfif>
								<cfif is_rate_checked EQ 1>
								<cfset debug && application.util.io.debugLog( "<h1>rate checking</h1><br>" )>
									<!--- get all the discount types --->
									<cfset qForAllDiscountTypes = dupProgramManager.GetDiscountTypes() />
									<!--- then check each rate based on the discount type --->
									<cfif qForAllDiscountTypes.recordCount GT 0>
										<cfloop query = "qForAllDiscountTypes">
										<cfswitch expression="#qForAllDiscountTypes.Product_Type_ID#">
										<cfcase value="1">
										<!---- fixed price --->
											<cfset debug && application.util.io.debugLog( "<h1>fixed price checking</h1><br>" )>
											<!--- If there is no component check --->
												<cfif is_component_checked EQ 0>
												<!--- If its an exact product match --->
														<cfif product_radio_index EQ 1>
															<cfset qFixedPrice = dupProgramManager.GetNotInProductFixedRates(cryp.value, check_contract_main_id)>
															<cfif qFixedPrice.recordCount NEQ 0>
																	<cfset duplicateprogram = "false">
																	<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 140" )>
															</cfif>
														<cfelse>
														<!--- If at least one product matches --->
															<cfset qFixedPrice = dupProgramManager.GetInProductFixedRates(cryp.value, check_contract_main_id)>
																<cfif qFixedPrice.recordCount GT 0>
																	<cfset duplicateprogram = "true">
																</cfif>
														</cfif>
												<cfelse>
													<cfset FixedComponentListQuery = dupProgramManager.GetFixedPriceComponent(cryp.value, check_contract_main_id)>
													<cfset FixedComponentList = valueList(FixedComponentListQuery.Program_Fixed_Component_Name_ID)>
														<!--- If its an exact component-product-rates combination match --->
													<cfif product_radio_index EQ 1>
															<cfloop list="#FixedComponentList#" index="FixedComp">
																<cfset qFixedPrice = dupProgramManager.GetNotInProductFixedRates(cryp.value, check_contract_main_id, is_component_checked, FixedComp)>
																	<cfif qFixedPrice.recordCount NEQ 0>
																		<cfset duplicateprogram = "false">
																		<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 150" )>
																		<cfbreak>
																	</cfif>
															</cfloop>
														<cfelse>
															<!--- If at least one component-product-rate combination match --->
															<cfloop list="#FixedComponentList#" index="FixedComp">
																<cfset qFixedPrice = dupProgramManager.GetInProductFixedRates(cryp.value, check_contract_main_id, is_component_checked, FixedComp)>
																	<cfif qFixedPrice.recordCount EQ 0>
																		<cfset duplicateprogram = "true">
																		 <cfbreak>
																	</cfif>
															</cfloop>
														</cfif>
														<!--- If there are no matching components --->
																<cfif ListLen(FixedComponentList) eq 0>
																	<cfset duplicateprogram = "false">
																	<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 160" )>
																</cfif>
														</cfif>
											</cfcase>
											<cfcase value = "2">
												<cfset debug && application.util.io.debugLog( "<h1>rebate checking</h1><br>" )>
												<!--- Rebate ---><!--- waiting for group level --->
												<!--- If there is no component check --->
													<cfif  is_component_checked EQ 0>
													<!--- If its an exact product match --->
														<cfif product_radio_index EQ 1>
															<cfset qRebate = dupProgramManager.GetNotInProductRebates(cryp.value, check_contract_main_id)>
															<cfif qRebate.recordCount NEQ 0>
																<cfset duplicateprogram = "false">
																<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 170" )>
															</cfif>
														<cfelse>
																<!--- If at least one product matches --->
															<cfset qRebate = dupProgramManager.GetInProductRebates(cryp.value, check_contract_main_id)>
																<cfif qRebate.recordCount GT 0>
																	<cfset duplicateprogram = "true">
																</cfif>
														</cfif>
													<cfelse>
													<cfset RebateComponentListQuery = dupProgramManager.GetRebateComponent(cryp.value, check_contract_main_id)>
													<cfset RebateComponentList = valueList(RebateComponentListQuery.Program_Rebates_Component_Name_ID)>
													<!--- If its an exact component-product-rates combination match --->
														<cfif product_radio_index EQ 1>
															<cfloop list="#RebateComponentList#" index="RebateComp">
																<cfset qRebate = dupProgramManager.GetNotInProductRebates(cryp.value, check_contract_main_id, is_component_checked, RebateComp)>
																	<cfif qRebate.recordCount NEQ 0>
																		<cfset duplicateprogram = "false">
																		<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 180" )>
																		<cfbreak>
																	</cfif>
															</cfloop>
														<cfelse>
														<!--- If at least one component-product-rate combination match --->
															<cfloop list="#RebateComponentList#" index="RebateComp">
																<cfset qRebate = dupProgramManager.GetInProductRebates(cryp.value, check_contract_main_id, is_component_checked, RebateComp)>
																	<cfif qRebate.recordCount GT 0>
																		<cfset duplicateprogram = "true">
																		<cfbreak>
																	</cfif>
															</cfloop>
														</cfif>
														<!--- If there are no matching components --->
																<cfif ListLen(RebateComponentList) eq 0>
																	<cfset duplicateprogram = "false">
																	<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 190" )>
																</cfif>
													</cfif>
												</cfcase>
												<cfcase value="3">
													<cfset debug && application.util.io.debugLog( "<h1>lump sum checking</h1><br>" )>
												<!--- lump sum --->
													<cfif ListFind(Discount_Types, 3) neq 0 OR is_component_checked EQ 0>
													<cfif product_radio_index EQ 1>
														<cfset qLumpSum = dupProgramManager.GetNotInLumSum(cryp.value, check_contract_main_id, is_component_checked)>
														<cfif qLumpSum.recordCount GT 0>
															<cfset duplicateprogram = "false">
															<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 200" )>
														</cfif>
													<cfelse>
															<!--- If at least one product matches --->
														<cfset qLumpSum = dupProgramManager.GetInLumSum(cryp.value, check_contract_main_id, is_component_checked)>
														<cfif qLumpSum.recordCount GT 0>
															<cfset duplicateprogram = "true">
														<cfelse>
															<cfset duplicateprogram = "false">
															<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 210" )>
														</cfif>
													</cfif>
												</cfif>
												</cfcase>
												<cfcase value="4"><!--- waiting for group level check --->
													<cfset debug && application.util.io.debugLog( "<h1>growth component checking</h1><br>" )>
												<!--- growth component --->
												<!--- If component is not to be checked --->
															<cfif  is_component_checked EQ 0>
														<!--- If its an exact product match --->
																<cfif product_radio_index EQ 1>
																	<cfset qGrowthComp = dupProgramManager.GetNotInProductGrowthComponentRates_New(cryp.value, check_contract_main_id)>
																	<cfif qGrowthComp.recordCount NEQ 0>
																		<cfset duplicateprogram = "false">
																		<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 220" )>
																	</cfif>
																<cfelse>
																	<cfset qGrowthComp = dupProgramManager.GetInProductGrowthComponentRates_New(cryp.value, check_contract_main_id)>
																	<cfif qGrowthComp.recordCount GT 0>
																		<cfset duplicateprogram = "true">
																	</cfif>
																</cfif>
															<cfelse>
															<cfset GrowthComponentListQuery = dupProgramManager.GetGrowthComponent(cryp.value, check_contract_main_id)>
															<cfset GrowthComponentList = valueList(GrowthComponentListQuery.Program_Growth_Components_Name_ID)>
															<!--- If its an exact component-product-rates combination match --->
															<cfif product_radio_index EQ 1>
																	<cfloop list="#GrowthComponentList#" index="GrowthComp">
																		<cfset qGrowthComp = dupProgramManager.GetNotInProductGrowthComponentRates_New(cryp.value, check_contract_main_id, is_component_checked, GrowthComp)>
																			<cfif qGrowthComp.recordCount NEQ 0>
																				<cfset duplicateprogram = "false">
																				<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 230" )>
																				<cfbreak>
																			</cfif>
																	</cfloop>
															<cfelse>
															<!--- If at least one component-product-rate combination match --->
															<cfloop list="#GrowthComponentList#" index="GrowthComp">
																<cfset qGrowthComp = dupProgramManager.GetInProductGrowthComponentRates_New(cryp.value, check_contract_main_id, is_component_checked, GrowthComp)>
																	<cfif qGrowthComp.recordCount GT 0>
																		<cfset duplicateprogram = "true">
																		<cfbreak>
																	</cfif>
															</cfloop>
														</cfif>
															<!--- If there are no matching components --->
																<cfif ListLen(GrowthComponentList) eq 0>
																	<cfset duplicateprogram = "false">
																	<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 240" )>
																</cfif>
													</cfif>
												</cfcase>
												<cfcase value="5">
													<cfset debug && application.util.io.debugLog( "<h1>formula pricing checking</h1><br>" )>
												<!---formula pricing ---->
													<cfif product_radio_index EQ 1>
														<cfset qFormulaPricing = dupProgramManager.GetNotInProductFormulaPricingRates(cryp.value, check_contract_main_id)>
														<cfif qFormulaPricing.recordCount GT 0>
															<cfset duplicateprogram = "false">
															<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 250" )>
														</cfif>
													<cfelse>
														<cfset qFormulaPricing = dupProgramManager.GetInProductFormulaPricingRates(cryp.value, check_contract_main_id)>
														<cfif qFormulaPricing.recordCount GT 0>
															<cfset duplicateprogram = "true">
														<cfelse>
															<cfset duplicateprogram = "false">
															<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 260" )>
														</cfif>
													</cfif>
												</cfcase>
												<cfcase value = "8">
													<cfset debug && application.util.io.debugLog( "<h1>off invoice checking</h1><br>" )>
													<!--- off invoice --->
													<!--- If there is no component check --->
														<cfif is_component_checked EQ 0>
													<!--- If its an exact product match --->
															<cfif product_radio_index EQ 1>
																<cfset qOffInvoice = dupProgramManager.GetNotInProductOffInvoiceRates(cryp.value, check_contract_main_id)>
																<cfif qOffInvoice.recordCount NEQ 0>
																	<cfset duplicateprogram = "false">
																	<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 270" )>
																</cfif>
															<cfelse>
													<!--- If at least one product matches --->
															<cfset qOffInvoice = dupProgramManager.GetInProductOffInvoiceRates(cryp.value, check_contract_main_id)>
																<cfif qOffInvoice.recordCount GT 0>
																	<cfset duplicateprogram = "true">
																</cfif>
															</cfif>
														<cfelse>
															<cfset OffInvoiceComponentListQuery = dupProgramManager.GetOffInvoicePriceComponent(cryp.value, check_contract_main_id)>
															<cfset OffInvoiceComponentList = valueList(OffInvoiceComponentListQuery.Program_OffInvoice_Component_Name_ID)>
													<!--- If its an exact component-product-rates combination match --->
													<cfif product_radio_index EQ 1>
															<cfloop list="#OffInvoiceComponentList#" index="OffInvoiceComp">
																<cfset qOffInvoice = dupProgramManager.GetNotInProductOffInvoiceRates(cryp.value, check_contract_main_id, is_component_checked, OffInvoiceComp)>
																<cfif qOffInvoice.recordCount NEQ 0>
																		<cfset duplicateprogram = "false">
																		<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 280" )>
																		<cfbreak>
																	</cfif>
															</cfloop>
													<cfelse>
													<!--- If at least one component-product-rate combination match --->
															<cfloop list="#OffInvoiceComponentList#" index="OffInvoiceComp">
																<cfset qOffInvoice = dupProgramManager.GetInProductOffInvoiceRates(cryp.value, check_contract_main_id, is_component_checked, OffInvoiceComp)>
																	<cfif qOffInvoice.recordCount EQ 0>
																		<cfset duplicateprogram = "true">
																		 <cfbreak>
																	</cfif>
															</cfloop>
													</cfif>
														<!--- If there are no matching components --->
																<cfif ListLen(OffInvoiceComponentList) eq 0>
																	<cfset duplicateprogram = "false">
																	<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 290" )>
																</cfif>
													</cfif>
											</cfcase>
											</cfswitch>
											<cfif  product_radio_index EQ 1 and duplicateprogram EQ "false">
												<cfbreak />
											</cfif>
											<!---
												in the first round, filter out those that doesn't have operator in common or distributor in common
												(refer to the existing program / overlapping program list)
												if it's check discount type at least, if duplicate program check in the discount type return true,
												exit from program since operator and distributor check has been done in the first place
											---->
											<cfif product_radio_index EQ 2 and duplicateprogram EQ "true"> <!--- at least --->
												<cfbreak />
											</cfif>
										</cfloop>
									</cfif>
								</cfif>
                            </cfif>
						</cfcase>
						<cfcase value="11">
							<cfset debug && application.util.io.debugLog( "<h1>******* Start LS Auto Pay Dollar Amount **********</h1><br>" )>
							<!--- IF LS AUTO PAY AND IT IS Dupe --->
							<cfif variables.Generic_Type EQ "LSAutoPay" AND duplicateprogram EQ "true">
								<!--- <cfoutput>#Item_Radio_Index#</cfoutput><cfabort> --->
								<cfset variables.getLSDollarMatch = dupProgramManager.GetInCompLumpSumDollar(cryp.value, check_contract_main_id) />
								<cfif variables.getLSDollarMatch.recordCount EQ 0>
									<cfset duplicateprogram = "false">
									<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 300" )>
								</cfif>
							</cfif>
						</cfcase>
						<cfcase value="3">
							<cfset debug && application.util.io.debugLog( "<h1>******* Start Operator checking **********</h1><br>" )>
						<!--- check operator --->
							<cfif Item_Radio_Index EQ 1>
								<cfset getcurrentOperators = dupProgramManager.GetNotInOperatorInfo(cryp.value, check_contract_main_id)>
								<cfif getcurrentOperators.recordCount EQ 0>
									<cfset getcurrentOperators = dupProgramManager.GetNotInOperatorInfo(check_contract_main_id, cryp.value)>
								</cfif>
								<cfif getcurrentOperators.recordCount NEQ 0>
									<cfset duplicateprogram = "false">
									<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 310" )>
								</cfif>
							<cfelse>
								<cfset getcurrentOperators = dupProgramManager.GetInOperatorInfo(cryp.value, check_contract_main_id)>
								 <cfset hasOperators = dupProgramManager.hasAnyOperators(cryp.value) >   <!--- Moved Outside of checkdates loop --->
								<cfset hasOperatorsForCheckContract = dupProgramManager.hasAnyOperators(check_contract_main_id) >
								<cfif getcurrentOperators.recordCount EQ 0 and ( hasOperators NEQ 0 or hasOperatorsForCheckContract NEQ 0 ) >    <!--- and ( hasOperators NEQ 0 or hasOperatorsForCheckContract NEQ 0 ) --->
									<cfset duplicateprogram = "false">
									<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 320" )>
								</cfif>
							</cfif>
						</cfcase>
                        <cfcase value="4">
							<cfset debug && application.util.io.debugLog( "<h1>******* Start Distributor checking **********</h1><br>" )>
						<!--- check distributor --->
							<cfif Item_Radio_Index EQ 1>
									<!--- D100784: REDO Improve performance of RFA process for programs with a large number of items/Anand Rao/29-Sep-2020
											The below code seems to be working fine except there was a query that was inside
										    loop which has been removed already in the earlier WR D100251
									--->
								<cfset getcurrentCustomers = dupProgramManager.GetNotInCustInfo(check_contract_main_id, cryp.value)>
								<cfif getcurrentCustomers.recordCount EQ 0>
									<cfset getcurrentCustomers = dupProgramManager.GetNotInCustInfo(cryp.value, check_contract_main_id)>
								</cfif>
								<!---  <cfif getcurrentCustomers.Count EQ 0> --->
								<cfif getcurrentCustomers.recordCount NEQ 0>
									<cfset duplicateprogram = "false">
									<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 330" )>
								</cfif>
							<cfelse>
								<cfset getcurrentCustomers = dupProgramManager.GetInCustInfo(cryp.value, check_contract_main_id)>
								<!--- <cfset hasCustsForCheckContract = dupProgramManager.hasAnyCusts(check_contract_main_id) > --->
								<!--- <cfset hasCusts = dupProgramManager.hasAnyCusts(cryp.value) > --->
								<cfscript>
									/******************************************************************************************************************
										Mark S :: 115090  performance fix
											For planners this is called in a loop and usually for the same 1-2 templates.  Put the var in the request scope so we can use it on the next loop
											For non-planners this is an extra step, but it is just a memory pointer and only lives for the request
									*******************************************************************************************************************/
									/* 		 SET variables.hasCustsForCheckContract		*/
							    	if ( !StructKeyExists(request, "hasCustsForCheckContract#check_contract_main_id#")){
							    		variables.hasCustsForCheckContract = dupProgramManager.hasAnyCusts(check_contract_main_id);
							    		request["hasCustsForCheckContract#check_contract_main_id#"] = variables.hasCustsForCheckContract;
							    	}
							    	else{
							    		variables.hasCustsForCheckContract = request["hasCustsForCheckContract#check_contract_main_id#"];
							    	}
							    	/* 		 SET variables.hasCusts		*/
							    	if ( !StructKeyExists(request, "hasCusts#cryp.value#")){
							    		variables.hasCusts = dupProgramManager.hasAnyCusts(cryp.value);
							    		request["hasCusts#cryp.value#"] = variables.hasCusts;
							    	}
							    	else{
							    		variables.hasCusts = request["hasCusts#cryp.value#"];
							    	}
							    </cfscript>

								<cfif getcurrentCustomers.recordCount EQ 0 and ( variables.hasCusts NEQ 0 or variables.hasCustsForCheckContract NEQ 0 )>
									<cfset duplicateprogram = "false">
									<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 340" )>
                                </cfif>
							</cfif>
						</cfcase>
						<cfcase value="10">
							<cfset debug && application.util.io.debugLog( "<h1>******* Start BROKER checking **********</h1><br>" )>
						<!--- check Broker --->
							<cfif Item_Radio_Index EQ 1>
								<cfset getcurrentBrokers = dupProgramManager.GetNotInBrokerInfo(check_contract_main_id, cryp.value)>
								<cfif getcurrentBrokers.recordCount EQ 0>
									<cfset getcurrentBrokers = dupProgramManager.GetNotInBrokerInfo(cryp.value, check_contract_main_id)>
								</cfif>
								<cfif getcurrentBrokers.recordCount NEQ 0>
									<cfset duplicateprogram = "false">
									<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 350" )>
								</cfif>
							<cfelse>
								<cfset getcurrentBrokers = dupProgramManager.GetInBrokerInfo(cryp.value, check_contract_main_id)>
								  <cfset hasBrokers = dupProgramManager.hasAnyBrokers(cryp.value) >  <!--- Moved Outside of checkdates loop   --->
								<cfset hasBrokersForCheckContract = dupProgramManager.hasAnyBrokers(check_contract_main_id) >
								<cfif getcurrentBrokers.recordCount EQ 0 and ( hasBrokers NEQ 0 or hasBrokersForCheckContract NEQ 0 )>		<!--- and ( hasBrokers NEQ 0 or hasBrokersForCheckContract NEQ 0 ) --->
									<cfset duplicateprogram = "false">
									<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 360" )>
								</cfif>
							</cfif>
						</cfcase>

					</cfswitch>
					<!--- break here ---->
					<cfif  duplicateprogram EQ "false" >
						<cfset variables.dupeItems = "" />
						<cfbreak />
					</cfif>
				</cfloop>
				<!--- <cfoutput><h1>#check_contract_main_id# ----- #check_contract_title# --- #duplicateprogram#</h1></cfoutput> --->
				<cfif duplicateprogram EQ "">
					<cfset duplicateprogram = "true">
				</cfif>

				<cfif duplicateprogram EQ "true">
					<cfparam name="variables.hasBrokers" default="0"/>
					<cfparam name="variables.hasCusts" default="0"/>
					<cfparam name="variables.hasOperators" default="0"/>
					<cfif dupProgramManager.hasAnyBrokers(cryp.value)><cfset variables.payeeMatch	= "Brokers"></cfif>
					<cfif hasCusts><cfset variables.payeeMatch = "Distributors"></cfif>
					<cfif dupProgramManager.hasAnyOperators(cryp.value)><cfset variables.payeeMatch = "Operators"></cfif>
				</cfif>
				<cfif duplicateprogram EQ "true" AND appSettings.getCheckAllDuplicateProgram()>
					<CFSET DuplicateProgramIDList = LISTAPPEND(DuplicateProgramIDList,check_contract_main_id,",")>
					<!--- <cfbreak /> --->
				<cfelseif duplicateprogram EQ "true">
					<cfbreak />
				</cfif>

				<cfset LastPercent = 0>
				<!--- This will return values of 1 through 10 (1 being 10%, 2 being 20%....10 being 100%) --->
				<cfset PercentDone = Int(Ceiling((CheckDates.currentrow/CheckDates.recordcount) * 100)/10)>

				<!--- Show the Image based on product count --->
				<cfif LastPercent neq PercentDone>
					<cfset Block = "Block" & PercentDone>
					<!--- dont show if coming from planners --->
					<cfif url.plannerId eq 0>
						<cfinclude template="/includes/show_progress_bar.cfm">
					</cfif>
					<cfset LastPercent = PercentDone>
				</cfif>

            </cfloop> <!--- end for check dates --->
		<cfelse>
			<cfset duplicateprogram = "false">
			<cfset debug && application.util.io.debugLog( "duplicateprogram = false :: 370" )>
			<cfexit>
		</cfif>
	</cfif> <!---end condition for allow_dup_programs--->
<!--- </cfif> --->

<cfif ListLen(DuplicateProgramIDList)  GT 0>
		<cfset duplicateprogram =  "true">
</cfif>
<!--- end checking --->
<script language="javascript">
//Show the progress in percent (100%)
 if(document.getElementById('ShowPercentProgress')){
	document.getElementById('ShowPercentProgress').innerHTML ='100%';
 }
//Hide the Progress Bar
 if(document.getElementById('Progress_Bar')){
 	document.getElementById('Progress_Bar').style.display = 'none';
 }
 </script>
