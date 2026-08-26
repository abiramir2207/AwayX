<!--- packet list ---->
<!---
	Discount type
	------------
	GetDiscountTypes(currid)
	GetAllDiscountTypes()
	------------
	
	Date
	-------------
	GetExistingContractInfo(startDate, endDate, contract_main_id, AtLeastMatch)
	GetOverLappingDateContractInfo(startDate, endDate, contract_main_id, AtLeastMatch)
	-------------
	
	Operators
	--------------
	GetNotInOperatorInfo(currid, dupid)
	GetInOperatorInfo(currid, dupid)
	hasAnyOperators(currid)
	--------------
	
	Distributors
	---------------
	GetNotInCustInfo(currid, dupid)
	GetInCustInfo(currid, dupid)
	hasAnyCusts(currid)
	---------------
	
	Product
	----------------
	--- item level ---
	GetNotInProductInfo(currid, dupid, DiscountType)
	GetInProductInfo(currid, dupid, DiscountType)
	--- group level ---
	GetNotInProductGroupInfo(currid, dupid)
	GetInProductGroupInfo(currid, dupid)
	GetNotInProductGroupInfoNew(currid, dupid)
	GetInProductGroupInfoNew(currid, dupid)
	--- check to determine whether product is group or item level
	IsProductGroup(currrid)
	----------------
	
	Rate
	----------------
		Fix Rate
		------------------
		GetNotInProductFixedRates(currid, dupid, IscomponentChecked, ComponentNum)
		GetInProductFixedRates(currid, dupid, IscomponentChecked, ComponentNum)
		------------------
		Rebate
		------------------
		GetNotInProductRebates(currid, dupid, IscomponentChecked, ComponentNum)
		GetInProductRebates(currid, dupid, IscomponentChecked, ComponentNum)
		------------------
		Component
		------------------
		GetGrowthComponents(currid, dupid)
		GetGrowthComponentTiers(cmpid, currid, dupid)
		GetInProductGrowthComponentRates_New(currid, dupid, IscomponentChecked, ComponentNum)
		GetNotInProductGrowthComponentRates_New(currid, dupid, IscomponentChecked, ComponentNum)
		GetNotInProductGrowthComponentRates(tier1_id, tier2_id)
		GetInProductGrowthComponentRates(tier1_id, tier2_id)
		------------------
		All components
		------------------
		GetFixedPriceComponent(currid, dupid)
		GetRebateComponent(currid, dupid)
		GetLumpSumComponent(currid, dupid)
		GetGrowthComponent(currid, dupid)
		GetOffInvoicePriceComponent(currid, dupid)
		------------------
		Formula Pricing
		------------------
		GetNotInProductFormulaPricingRates(currid, dupid)
		GetInProductFormulaPricingRates(currid, dupid)
		------------------
		Off Invoice 
		------------------
		GetNotInProductOffInvoiceRates(currid, dupid, IscomponentChecked, ComponentNum)
		GetInProductOffInvoiceRates(currid, dupid, IscomponentChecked, ComponentNum)
		------------------
		Lump Sum
		------------------
		GetNotInLumSum(currid, dupid)
		GetInLumSum(currid, dupid)
		------------------
	----------------
---->
<!--- end the list --->

<cfcomponent displayname="DuplicateProgramManager" hint="this is the duplicate program manager class to handle all the required business logic for duplicate programs">
	<!--- init --->
	<cfset variables.comparedProgramID = "" />
	<cffunction name="init" returntype="DuplicateProgramManager" output="false">
		<cfargument name="comparedProgramID" 	type="numeric" required="true">
		<cfargument name="comparedTemplateID" 	type="numeric" required="true">
		<cfset setComparedProgramID(arguments.comparedProgramID) />
		<cfif isDefined("arguments.comparedTemplateID") >
			<cfset dupTemplateManager = CreateObject("component","components.programs.template.DuplicateTemplateManager").init(arguments.comparedTemplateID,'Duplicate Program',1) />
		</cfif>
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />		
		<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
		<cfset operatingGroupManager = CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
		<cfset ProductGroupAttributeManager = CreateObject("component", "components.Products.Group.ProductGroupAttributeManager").init() />
		
		<cfreturn this />
	</cffunction>
	<!--- getter --->
	<cffunction name="getComparedProgramID" returntype="numeric" access="public">
		<cfreturn variables.comparedProgramID />
	</cffunction>
	<!--- setter --->
	<cffunction name="setComparedProgramID" returntype="void" access="private">
		<cfargument name="comparedProgramID" type="numeric" required="true">
		<cfset variables.comparedProgramID = arguments.comparedProgramID />
	</cffunction>
	<!--- methods --->
	<cffunction name="hasDistributors" returntype="boolean" access="package">
		<CFQUERY name="qGetDistributors" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			select 	distinct BSA_Foodservice_Customers_ID
			from 	contract_distributors 
			where 	contract_main_id = #this.getComparedProgramID()#
			and		deleted = 0		
		</CFQUERY>
		<cfif qGetDistributors.recordCount GT 0>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<cffunction name="hasOperators" returntype="boolean" access="package">
		<CFQUERY name="qGetOperators" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			select 	distinct BSA_Operator_ID
			from 	contract_operators 
			where 	contract_main_id = #this.getComparedProgramID()#
			and		deleted = 0
		</CFQUERY>
		<cfif qGetOperators.recordCount GT 0>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>

	<!--- get existing contract information --->
	<cffunction name="GetExistingContractInfo" 	access="public" returntype="query" >
		<cfargument name="exContractStartDate" 	type="date" required="true" />
		<cfargument name="exContractEndDate"	type="date" required="true" />
		<cfargument name="id" type="string" required="true" />
		<cfargument name="AtLeastMatch"	type="numeric" required="true" default ="2" />

		<cfset appSettings = genSettingsManager.get()>
		<CFIF dupTemplateManager.requireTemplateCheck()>
			<CFSET GenericTypeCriteria = dupTemplateManager.GetGenericTypeDefinition(arguments.id)>
		</CFIF>
		
		<cfset qDiscountTypes = this.getDiscountTypes() />
		<cfset CurrentProgramDiscTypeList = ValueList(qDiscountTypes.product_type_id)>
		
		<CFQUERY name="qGetExisingContractInfo" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
					SELECT 	distinct contract_main_id,contract_number, contract_title, creator_id, ProgramType_ID
					INTO ##Contract_Ids
					FROM	CONTRACT_MAIN 
					WHERE	Contract_Status_Type_IDX > 2
					<!--- Do not consider Lost Programs --->
					AND		Contract_Status_Type_IDX <> 8
					AND		contract_Start_date = '#arguments.exContractStartDate#' 
					and 	contract_End_Date = '#arguments.exContractEndDate#'
					AND		contract_main_id <> '#arguments.id#'				
					and 	isnull(manual_cancel, 0) = 0
					and		isnull(Flagged_As_Purged, 0) = 0
					and 	isnull(Force_Expiration_Flag, 0) = 0
					and		contract_number <> (select contract_number from contract_main  where contract_main_id = '#arguments.id#')
					and 	deleted = 0 

			<cfset FoundCondition = 0>	
			SELECT * FROM ##Contract_Ids

			<!--- "FoundCondition" is used to see whether to use "WHERE" clause or "AND" clause --->
			----check component
			<CFIF dupTemplateManager.requireComponentCheck()>
			<cfset FoundCondition = 1>
				where exists
				(
				SELECT top 0 contract_main_id from ##Contract_Ids
				
				<cfif ListFInd(CurrentProgramDiscTypeList, 1)>
				UNION ALL
				
				SELECT pfc2.Program_ID
				FROM Program_Fixed_Component pfc1,Program_Fixed_Component pfc2 
				WHERE pfc1.Program_Fixed_Component_Name_ID = pfc2.Program_Fixed_Component_Name_ID
				AND pfc1.Program_ID = #this.getComparedProgramID()#				
				AND pfc1.Deleted = 0
				AND pfc2.Deleted = 0
				AND ##Contract_Ids.contract_main_id = pfc2.Program_ID
				</cfif>
				
				<cfif ListFInd(CurrentProgramDiscTypeList, 2)>
				UNION ALL
				
				SELECT prc2.Program_ID
				FROM Program_Rebates_Component prc1,Program_Rebates_Component prc2 
				WHERE prc1.Program_Rebates_Component_Name_ID = prc2.Program_Rebates_Component_Name_ID
				AND prc1.Program_ID = #this.getComparedProgramID()#								
				AND prc1.Deleted = 0
				AND prc2.Deleted = 0
				AND ##Contract_Ids.contract_main_id = prc2.Program_ID
				</cfif>

				<cfif ListFInd(CurrentProgramDiscTypeList, 3)>
				UNION ALL

				SELECT pls2.Program_ID
				FROM Program_Lump_Sums pls1, Program_Lump_Sums pls2 
				WHERE pls1.Program_ID = #this.getComparedProgramID()#							
				AND pls1.Deleted = 0
				AND pls2.Deleted = 0
				AND ##Contract_Ids.contract_main_id = pls2.Program_ID	
				AND pls1.Program_Lump_Sum_Name_ID = pls2.Program_Lump_Sum_Name_ID
				</cfif>
				
				<cfif ListFInd(CurrentProgramDiscTypeList, 4)>
				UNION ALL

				SELECT pgc2.Program_ID
				FROM Program_Growth_Components pgc1,Program_Growth_Components pgc2 
				WHERE pgc1.Program_ID = #this.getComparedProgramID()#
				AND pgc1.Deleted = 0
				AND pgc2.Deleted = 0
				AND ##Contract_Ids.contract_main_id = pgc2.Program_ID	
				AND pgc1.Program_Growth_Components_Name_ID = pgc2.Program_Growth_Components_Name_ID 			
				</cfif>
				
				<cfif ListFInd(CurrentProgramDiscTypeList, 5)>
				UNION ALL

				SELECT poc2.Program_ID
				FROM Program_OffInvoice_Component poc1,Program_OffInvoice_Component poc2 
				WHERE poc1.Program_ID = #this.getComparedProgramID()#
				AND poc1.Deleted = 0
				AND poc2.Deleted = 0
				AND ##Contract_Ids.contract_main_id = poc2.Program_ID
				AND poc1.Program_OffInvoice_Component_Name_ID = poc2.Program_OffInvoice_Component_Name_ID
				</cfif> 
				)
		</CFIF>
		------- check template
		<cfif FoundCondition eq 0>
				<cfset UseClause = 'where'>
		<cfelse>
				<cfset UseClause = 'and'>
		</cfif>
		<CFIF dupTemplateManager.requireTemplateCheck()>
		<cfset FoundCondition = 1>
			<CFIF GenericTypeCriteria.ITEM_RADIO_INDEX EQ 1>
			
					#UseClause# ##Contract_Ids.ProgramType_ID IN (#templateManager.getThisTemplateIDList(arguments.id)#)
			<CFELSE>
				#UseClause# exists
					(
						select distinct ##Contract_Ids.contract_main_id
						from Program_Control_Panel_Options pcpo
						WHERE ##Contract_Ids.ProgramType_ID = pcpo.ProgramControl_Panel_Options_ID
						AND pcpo.Generic_Type = '#GenericTypeCriteria.Generic_Type#'
					)
			</CFIF>
		</CFIF>
		<cfif FoundCondition eq 0>
				<cfset UseClause = 'where'>
		<cfelse>
				<cfset UseClause = 'and'>
		</cfif>
		------- Check Spending Category
		<CFIF appSettings.getOperatingGroupOn() AND dupTemplateManager.requireSpendingCategoryCheck()>
		<cfset FoundCondition = 1>
			#UseClause# exists
			(
			SELECT DISTINCT Program_Operating_Group.Program_ID FROM Program_Operating_Group
			WHERE ##Contract_Ids.contract_main_id = Program_Operating_Group.Program_ID
			AND Program_Operating_Group.Operating_Group_ID = #operatingGroupManager.getProgramOperatingGroupID(2,arguments.id)#
			)
		</CFIF>
		<cfif FoundCondition eq 0>
				<cfset UseClause = 'where'>
		<cfelse>
				<cfset UseClause = 'and'>
		</cfif>
		-------check distributor
		<cfif this.hasDistributors() and dupTemplateManager.requireDistributorCheck() >
		<cfset FoundCondition = 1>
			#UseClause# exists
				(
					select distinct contract_main_id
					from contract_distributors cd3 
					where cd3.contract_main_id = ##Contract_Ids.contract_main_id
					and cd3.deleted = 0
					and exists
						(	select 	distinct BSA_Foodservice_Customers_ID
							from	contract_distributors cd2 
							where 	cd2.contract_main_id = #this.getComparedProgramID()#
							and cd3.BSA_Foodservice_Customers_ID = cd2.BSA_Foodservice_Customers_ID
							and cd2.deleted = 0
						)
				)
		</cfif>
		<cfif FoundCondition eq 0>
				<cfset UseClause = 'where'>
		<cfelse>
				<cfset UseClause = 'and'>
		</cfif>
			-------check operator
		<cfif this.hasOperators() and dupTemplateManager.requireOperatorCheck() >
		<cfset FoundCondition = 1>
				#UseClause# exists
				(
					select distinct CTO.contract_main_id	
					FROM Contract_Operators CTO 
							Inner Join	BSA_Operator CO 
							on 	CO.BSA_Operator_ID = CTO.BSA_Operator_ID
							where CTO.deleted = 0
							and	exists 
								(
									select distinct CTO1.contract_main_id	
									FROM Contract_Operators CTO1 
									Inner Join  BSA_Operator CO1 
											on  CO1.BSA_Operator_ID = CTO1.BSA_Operator_ID
											where CTO1.Contract_Main_ID = #this.getComparedProgramID()#
											and CTO1.deleted = 0
											<!---and CO1.Operator_Type = CO.Operator_Type--->
											and (
													CO.BSA_Operator_ID = CO1.BSA_Operator_ID
												)							
								)			
				and CTO.contract_main_id = ##Contract_Ids.contract_main_id
				)			
		</cfif>
		<cfif FoundCondition eq 0>
				<cfset UseClause = 'where'>
		<cfelse>
				<cfset UseClause = 'and'>
		</cfif>
		----- check discount types (For 'Exact' matches (AtLeastMatch =1), check for programs having the exact same discount types only)
		<cfif qDiscountTypes.recordCount GT 0 and dupTemplateManager.requireDiscountTypeCheck() >
			<cfset FoundCondition = 1>
			#UseClause# exists
				(
					select distinct contract_main_id
					from contract_products 
					where contract_products.contract_main_id = ##Contract_Ids.contract_main_id
					<cfif arguments.AtLeastMatch eq 2>
					and contract_products.product_type_id IN (<cfif len(ValueList(qDiscountTypes.product_type_id)) GT 0>#ValueList(qDiscountTypes.product_type_id)#<cfelse>''</cfif>)
					<cfelse>
					and contract_products.product_type_id = #ListGetAt(ValueList(qDiscountTypes.product_type_id),1)#
					</cfif>	
					and  contract_products.deleted = 0
					<cfif arguments.AtLeastMatch eq 1>						
						<cfset DiscTypeList = ListDeleteAt(ValueList(qDiscountTypes.product_type_id),1)>
						<cfset qAllDiscountTypes = this.getAllDiscountTypes() />
						<cfset AllDiscTypeList = ValueList(qAllDiscountTypes.discount_type_id)>
						<!--- If a discount type exists --->
							<cfloop list="#AllDiscTypeList#" index="DiscType">	
								<cfif ListFind(DiscTypeList,DiscType) neq 0>
									and exists(
									select distinct cp3.contract_main_id
									from contract_products cp3 
									where cp3.contract_main_id = ##Contract_Ids.contract_main_id
									and  cp3.deleted = 0
									and cp3.product_type_id = #DiscType#
									)
								</cfif>
							</cfloop>
							<!--- Look for discount types that do not exist --->
									and not exists(
									select distinct cp4.contract_main_id
									from contract_products cp4 
									where cp4.contract_main_id = ##Contract_Ids.contract_main_id
									and  cp4.deleted = 0
									and exists(
											select discount_type_id
											from discount_type 
											where discount_type_id not in(#CurrentProgramDiscTypeList#)
											and cp4.product_type_id = discount_type.discount_type_id
										)
									)
					</cfif>
				 )		
		</cfif>
		--order by 1 desc
			if object_id('tempdb..##Contract_Ids') is not null 
			drop table ##Contract_Ids 
		</CFQUERY>
		<cfreturn qGetExisingContractInfo />
	</cffunction>
	
	<!--- get overlapping date contract information --->
	<cffunction name="GetOverLappingDateContractInfo" 	access="public" returntype="query" >
		<cfargument name="exContractStartDate" 	type="date" required="true" />
		<cfargument name="exContractEndDate"	type="date" required="true" />
		<cfargument name="id" type="string" required="true" />
		<cfargument name="AtLeastMatch"	type="numeric" required="true" default ="2" />
		<cfset appSettings = genSettingsManager.get()>
		<CFIF dupTemplateManager.requireTemplateCheck()>
			<CFSET GenericTypeCriteria = dupTemplateManager.GetGenericTypeDefinition(arguments.id)>
		</CFIF>
		
		<cfset qDiscountTypes = this.getDiscountTypes() />
		<cfset CurrentProgramDiscTypeList = ValueList(qDiscountTypes.product_type_id)>

		<CFQUERY name="qGetOverLappingDateContractInfo" datasource="#application.datasource#">
			if object_id('tempdb..##Contract_Ids') is not null 
			drop table ##Contract_Ids 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
					SELECT 	distinct contract_main_id,contract_number, contract_title, creator_id,ProgramType_ID
					INTO ##Contract_Ids
					FROM	CONTRACT_MAIN 
					WHERE	Contract_Status_Type_IDX > 2
					<!--- Do not consider Lost Programs --->
					AND		Contract_Status_Type_IDX <> 8
					and		((contract_Start_date >= '#arguments.exContractStartDate#'  AND contract_Start_date <= '#arguments.exContractEndDate#')
							 or (contract_Start_date <= '#arguments.exContractStartDate#'  AND contract_End_date >= '#arguments.exContractStartDate#') )
					and contract_main_id <> '#arguments.id#'
					and isnull(manual_cancel, 0) = 0
					and	isnull(Flagged_As_Purged, 0) = 0
					and isnull(Force_Expiration_Flag, 0) = 0
					and	contract_number <> (select contract_number from contract_main where contract_main_id = '#arguments.id#')
					and deleted = 0

			<cfset FoundCondition = 0>
			SELECT * FROM ##Contract_Ids
	
			----check component 
			<CFIF dupTemplateManager.requireComponentCheck()>
			<cfset FoundCondition = 1>
				where exists
				(
				SELECT top 0 contract_main_id from ##Contract_Ids
				
				<cfif ListFInd(CurrentProgramDiscTypeList, 1)>
				UNION ALL
				
				SELECT pfc2.Program_ID
				FROM Program_Fixed_Component pfc1,Program_Fixed_Component pfc2
				WHERE pfc1.Program_Fixed_Component_Name_ID = pfc2.Program_Fixed_Component_Name_ID 
				AND pfc1.Program_ID = #this.getComparedProgramID()#					
				AND pfc1.Deleted = 0
				AND pfc2.Deleted = 0							
				AND ##Contract_Ids.contract_main_id = pfc2.Program_ID
				</cfif>
				
				<cfif ListFInd(CurrentProgramDiscTypeList, 2)>
				UNION ALL
				
				SELECT prc2.Program_ID
				FROM Program_Rebates_Component prc1,Program_Rebates_Component prc2 
				WHERE prc1.Program_Rebates_Component_Name_ID = prc2.Program_Rebates_Component_Name_ID
				AND prc1.Program_ID = #this.getComparedProgramID()#	
				AND prc1.Deleted = 0
				AND prc2.Deleted = 0
				AND ##Contract_Ids.contract_main_id = prc2.Program_ID
				</cfif>

				<cfif ListFInd(CurrentProgramDiscTypeList, 3)>
				UNION ALL

				SELECT pls2.Program_ID
				FROM Program_Lump_Sums pls1,Program_Lump_Sums pls2 
				WHERE pls1.Program_ID = #this.getComparedProgramID()#	
				AND pls1.Deleted = 0
				AND pls2.Deleted = 0
				AND ##Contract_Ids.contract_main_id = pls2.Program_ID
				AND pls1.Program_Lump_Sum_Name_ID = pls2.Program_Lump_Sum_Name_ID		
				
				</cfif>

				<cfif ListFInd(CurrentProgramDiscTypeList, 4)>
				UNION ALL

				SELECT pgc2.Program_ID
				FROM Program_Growth_Components pgc1,Program_Growth_Components pgc2 
				WHERE pgc1.Program_Growth_Components_Name_ID = pgc2.Program_Growth_Components_Name_ID
				AND pgc2.Deleted = 0
				AND pgc1.Deleted = 0 
				AND ##Contract_Ids.contract_main_id = pgc2.Program_ID
				AND pgc1.Program_ID = #this.getComparedProgramID()#				
				
				</cfif>

				<cfif ListFInd(CurrentProgramDiscTypeList, 5)>
				UNION ALL

				SELECT poc2.Program_ID
				FROM Program_OffInvoice_Component poc1,Program_OffInvoice_Component poc2 
				WHERE poc1.Program_OffInvoice_Component_Name_ID = poc2.Program_OffInvoice_Component_Name_ID
				AND poc2.Deleted = 0
				AND poc1.Deleted = 0
				AND ##Contract_Ids.contract_main_id = poc2.Program_ID
				AND poc1.Program_ID = #this.getComparedProgramID()#
				</cfif>
				)
		</CFIF>
		<cfif FoundCondition eq 0>
				<cfset UseClause = 'where'>
		<cfelse>
				<cfset UseClause = 'and'>
		</cfif>
		------- check template
		<CFIF dupTemplateManager.requireTemplateCheck()>
		<cfset FoundCondition = 1>
			<CFIF GenericTypeCriteria.ITEM_RADIO_INDEX EQ 1>
			
						#UseClause# ##Contract_Ids.ProgramType_ID IN (#templateManager.getThisTemplateIDList(arguments.id)#)
			<CFELSE>
				#UseClause# exists
					(
						select distinct ##Contract_Ids.contract_main_id
						from Program_Control_Panel_Options pcpo
						WHERE ##Contract_Ids.ProgramType_ID = pcpo.ProgramControl_Panel_Options_ID
						AND pcpo.Generic_Type = '#GenericTypeCriteria.Generic_Type#'
					)
			</CFIF>
		</CFIF>
		<cfif FoundCondition eq 0>
				<cfset UseClause = 'where'>
		<cfelse>
				<cfset UseClause = 'and'>
		</cfif>
		------- Check Spending Category
		<CFIF appSettings.getOperatingGroupOn() AND dupTemplateManager.requireSpendingCategoryCheck()>
		<cfset FoundCondition = 1>
			#UseClause# exists
			(
			SELECT DISTINCT Program_Operating_Group.Program_ID FROM Program_Operating_Group
			WHERE ##Contract_Ids.contract_main_id = Program_Operating_Group.Program_ID
			AND Program_Operating_Group.Operating_Group_ID = #operatingGroupManager.getProgramOperatingGroupID(2,arguments.id)#
			)
		</CFIF>
		<cfif FoundCondition eq 0>
				<cfset UseClause = 'where'>
		<cfelse>
				<cfset UseClause = 'and'>
		</cfif>
		-------check distributor
		<cfif this.hasDistributors() and dupTemplateManager.requireDistributorCheck() >
		<cfset FoundCondition = 1>
			#UseClause# exists
				(
					select distinct cd3.contract_main_id
					from contract_distributors cd3 
					where cd3.contract_main_id = ##Contract_Ids.contract_main_id
					and cd3.deleted = 0
					and exists
						(	select 	distinct BSA_Foodservice_Customers_ID
							from	contract_distributors cd4 
							where 	contract_main_id = #this.getComparedProgramID()#
							and cd3.BSA_Foodservice_Customers_ID = cd4.BSA_Foodservice_Customers_ID
						)
				)
		</cfif>
		<cfif FoundCondition eq 0>
				<cfset UseClause = 'where'>
		<cfelse>
				<cfset UseClause = 'and'>
		</cfif>
		-------check operator
			<cfif this.hasOperators() and dupTemplateManager.requireOperatorCheck() >
			<cfset FoundCondition = 1>
			#UseClause# exists
				(
					select distinct CTO.contract_main_id	
					FROM Contract_Operators CTO
					Inner Join	BSA_Operator CO
							on 	CO.BSA_Operator_ID = CTO.BSA_Operator_ID
							where CTO.deleted = 0
							and	exists 
								(
									select distinct CTO1.contract_main_id	
									FROM Contract_Operators CTO1
									Inner Join  BSA_Operator CO1
											on  CO1.BSA_Operator_ID = CTO1.BSA_Operator_ID
											where CTO1.Contract_Main_ID = #this.getComparedProgramID()#
											and CTO1.deleted = 0
											<!---and CO1.Operator_Type = CO.Operator_Type--->
											and (
													CO.BSA_Operator_ID = CO1.BSA_Operator_ID
												)							
								)
			and CTO.contract_main_id = ##Contract_Ids.contract_main_id
				)
			</cfif>
		<cfif FoundCondition eq 0>
				<cfset UseClause = 'where'>
		<cfelse>
				<cfset UseClause = 'and'>
		</cfif>
		----- check discount types (For 'Exact' matches (AtLeastMatch =1), check for programs having the exact same discount types only)
			<cfif qDiscountTypes.recordCount GT 0 and dupTemplateManager.requireDiscountTypeCheck() >
			<cfset FoundCondition = 1>
			#UseClause# exists
				(
					select distinct contract_products.contract_main_id
					from contract_products
					where contract_products.contract_main_id = ##Contract_Ids.contract_main_id					
					<cfif arguments.AtLeastMatch eq 2>
					and contract_products.product_type_id in (<cfif len(ValueList(qDiscountTypes.product_type_id)) GT 0>#ValueList(qDiscountTypes.product_type_id)#<cfelse>''</cfif>)
					<cfelse>
					and contract_products.product_type_id = #ListGetAt(ValueList(qDiscountTypes.product_type_id),1)#
					</cfif>
					and  contract_products.deleted = 0
					<cfif arguments.AtLeastMatch eq 1>
						<cfset DiscTypeList = ListDeleteAt(ValueList(qDiscountTypes.product_type_id),1)>
						<cfset qAllDiscountTypes = this.getAllDiscountTypes() />
						<cfset AllDiscTypeList = ValueList(qAllDiscountTypes.discount_type_id)>
						<!--- If a discount type exists --->
							<cfloop list="#AllDiscTypeList#" index="DiscType">	
								<cfif ListFind(DiscTypeList,DiscType) neq 0>
									and exists(
									select distinct cp3.contract_main_id
									from contract_products cp3 
									where cp3.contract_main_id = ##Contract_Ids.contract_main_id
									and  cp3.deleted = 0
									and cp3.product_type_id = #DiscType#
									)
								</cfif>
							</cfloop>
							<!--- Look for discount types that do not exist --->
									and not exists(
									select distinct cp4.contract_main_id
									from contract_products cp4 
									where cp4.contract_main_id = ##Contract_Ids.contract_main_id
									and  cp4.deleted = 0
									and exists(
											select discount_type_id
											from discount_type 
											where discount_type_id not in(#CurrentProgramDiscTypeList#)
											and cp4.product_type_id = discount_type.discount_type_id
										)
									)
					</cfif>
				 )		
			</cfif>
		--order by 1 desc
			if object_id('tempdb..##Contract_Ids') is not null 
			drop table ##Contract_Ids 
		</CFQUERY>
		<cfreturn qGetOverLappingDateContractInfo />
	</cffunction>
	
	<!-----$$$$$$$$$$$$$$$$$$$	check for customer $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$----->
	<!--- compare two programs and get the list of customers not exisiting in the current program --->
	<cffunction name="GetNotInCustInfo" 	access="public" returntype="query" >
		<cfargument name="currid" 			type="string" required="true" />
		<cfargument name="existingid" 		type="string" required="true" />
		<CFQUERY name="qGetNotInCustInfo" 	datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT distinct BSA_Foodservice_Customers_ID
			FROM Contract_Distributors cd1 
			WHERE
				cd1.Contract_Main_ID = '#arguments.currid#'
				and cd1.deleted =0
				AND NOT EXISTS
					(	SELECT BSA_Foodservice_Customers_ID
						FROM Contract_Distributors cd2 
						WHERE	cd2.Contract_Main_ID = #arguments.existingid# and cd2.deleted = 0
						AND cd1.BSA_Foodservice_Customers_ID = cd2.BSA_Foodservice_Customers_ID
					)
		</CFQUERY>
		<cfreturn qGetNotInCustInfo />
	</cffunction>
	
	<!--- compare two programs and get the list of customers exisiting in the both program --->
	<cffunction name="GetInCustInfo" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" 	type="string" required="true" />
		<CFQUERY name="qGetInCustInfo" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT distinct BSA_Foodservice_Customers_ID
			FROM Contract_Distributors cd1 
			WHERE
				cd1.Contract_Main_ID = '#arguments.currid#'
				and cd1.deleted =0
				AND EXISTS
					(	SELECT BSA_Foodservice_Customers_ID
						FROM Contract_Distributors cd2 
						WHERE	cd2.Contract_Main_ID = #arguments.existingid# and cd2.deleted = 0
						AND cd1.BSA_Foodservice_Customers_ID = cd2.BSA_Foodservice_Customers_ID
					)
		</CFQUERY>
		<cfreturn qGetInCustInfo />
	</cffunction>
	
	<cffunction name="hasAnyCusts" 	access="public" returntype="numeric" >
		<cfargument name="currid" type="string" required="true" />
		<CFQUERY name="qHasAnyCusts" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT distinct BSA_Foodservice_Customers_ID
			FROM Contract_Distributors  
			WHERE
				Contract_Main_ID = '#arguments.currid#'
				and deleted =0
		</CFQUERY>
		<cfreturn qHasAnyCusts.recordCount />
	</cffunction>
		
	<!--- $$$$$$$$$$$$$$$$$$$	end check for customers $$$$$$$$$$$$$$$$$$$$$$$$$$--->
	
	<!----$$$$$$$$$$$$$$$$$$$$ check for operator $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$---->
	<cffunction name="hasAnyOperators" 	access="public" returntype="numeric" >
		<cfargument name="currid" type="string" required="true" />
		<CFQUERY name="qHasAnyOperators" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT distinct BSA_Operator_ID
			FROM Contract_Operators 
			WHERE	Contract_Main_ID = '#arguments.currid#'
			and 	deleted = 0
		</CFQUERY>
		<cfreturn qHasAnyOperators.recordCount />
	</cffunction>
	
	<!--- compare two programs and get the list of operators not exisiting in the current program --->
	<cffunction name="GetNotInOperatorInfo" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" 	type="string" required="true" />
		<CFQUERY name="qGetNotInOperatorInfo" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT distinct CO.BSA_Operator_ID, COP.Operator_Type
			FROM Contract_Operators CO 
			inner join BSA_Operator COP   on COP.BSA_Operator_ID = CO.BSA_Operator_ID
			WHERE	CO.Contract_Main_ID = '#arguments.currid#'
			and 	CO.deleted = 0
			AND 	Not Exists
					(	SELECT 	CO1.BSA_Operator_ID,COP1.Operator_Type
						FROM 	Contract_Operators CO1 
						inner join BSA_Operator COP1   on COP1.BSA_Operator_ID = CO1.BSA_Operator_ID
						WHERE 	CO1.Contract_Main_ID = #arguments.existingid#
						and 	CO1.deleted = 0 
						<!---and		COP1.Operator_Type = COP.Operator_Type--->
						and	(
								CO1.BSA_Operator_ID = 	CO.BSA_Operator_ID
							)		
					)
		</CFQUERY>
		<cfreturn qGetNotInOperatorInfo />
	</cffunction>
	
	<!--- compare two programs and get the list of operators exisiting in the both programs --->
	<cffunction name="GetInOperatorInfo" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
		<CFQUERY name="qGetInOperatorInfo" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT distinct CO.BSA_Operator_ID, COP.Operator_Type
			FROM Contract_Operators CO 
			inner join BSA_Operator COP   on COP.BSA_Operator_ID = CO.BSA_Operator_ID
			WHERE	CO.Contract_Main_ID = '#arguments.currid#'
			and 	CO.deleted = 0
			AND 	Exists
					(	SELECT 	CO1.BSA_Operator_ID,COP1.Operator_Type
						FROM 	Contract_Operators CO1 
						inner join BSA_Operator COP1  on COP1.BSA_Operator_ID = CO1.BSA_Operator_ID
						WHERE 	CO1.Contract_Main_ID = #arguments.existingid#
						and 	CO1.deleted = 0 
						<!---and		COP1.Operator_Type = COP.Operator_Type--->
						and	(
								CO1.BSA_Operator_ID = 	CO.BSA_Operator_ID
							)		
					)
		</CFQUERY>
		<cfreturn qGetInOperatorInfo />
	</cffunction>
	
	<!---$$$$$$$$$$$$$$$$$$$ end check for operator $$$$$$$$$$$$$$$$$$$$$$$$--->
	
	<!-----$$$$$$$$$$$$$$$$$$$	check for BROKER $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$----->
	<!--- compare two programs and get the list of customers not exisiting in the current program --->
	<cffunction name="GetNotInBrokerInfo" 	access="public" returntype="query" >
		<cfargument name="currid" 			type="string" required="true" />
		<cfargument name="existingid" 		type="string" required="true" />
		<CFQUERY name="qGetNotInBrokerInfo" 	datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT distinct BSA_Foodservice_Brokers_ID
			FROM Contract_Brokers Br1 
			WHERE
				Br1.Contract_Main_ID = '#arguments.currid#'
				and Br1.deleted =0
				AND NOT EXISTS
					(	SELECT BSA_Foodservice_Brokers_ID
						FROM Contract_Brokers Br2
						WHERE	Br2.Contract_Main_ID = #arguments.existingid# and Br2.deleted = 0
						AND Br1.BSA_Foodservice_Brokers_ID = Br2.BSA_Foodservice_Brokers_ID
					)
		</CFQUERY>
		<cfreturn qGetNotInBrokerInfo />
	</cffunction>
	
	<!--- compare two programs and get the list of customers exisiting in the both program --->
	<cffunction name="GetInBrokerInfo" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" 	type="string" required="true" />
		<CFQUERY name="qGetInBrokerInfo" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT distinct BSA_Foodservice_Brokers_ID
			FROM Contract_Brokers Br1 
			WHERE
				Br1.Contract_Main_ID = '#arguments.currid#'
				and Br1.deleted =0
				AND EXISTS
					(	SELECT BSA_Foodservice_Brokers_ID
						FROM Contract_Brokers Br2
						WHERE	Br2.Contract_Main_ID = #arguments.existingid# and Br2.deleted = 0
						AND Br1.BSA_Foodservice_Brokers_ID = Br2.BSA_Foodservice_Brokers_ID
					)
		</CFQUERY>
		<cfreturn qGetInBrokerInfo />
	</cffunction>
	
	<cffunction name="hasAnyBrokers" 	access="public" returntype="numeric" >
		<cfargument name="currid" type="string" required="true" />
		<CFQUERY name="qHasAnyBrokers" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT distinct BSA_Foodservice_Brokers_ID
			FROM Contract_Brokers 
			WHERE
				Contract_Main_ID = '#arguments.currid#'
				and deleted =0
		</CFQUERY>
		<cfreturn qHasAnyBrokers.recordCount />
	</cffunction>
		
	<!---$$$$$$$$$$$$$$$$$$ check for program lump sum $$$$$$$$$$$$$$$$$$$$$$--->
	
<!---compare two programs and get the list of program lump sum not exisiting in the current program --->
	<cffunction name="GetNotInLumpSumInfo" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
		<CFQUERY name="qGetNotInLumpSumInfo" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			select	distinct pls.Lump_Sum_Amount 
			from 	Program_Lump_Sum_Product_Data pd ,program_lump_sums pls 
			where 	pls.Program_ID = '#arguments.currid#'
			and 	pls.deleted = 0
			and 	pd.deleted = 0
			and 	pls.Program_Lump_Sum_ID = pd.Program_Lump_Sum_ID
			and	Not Exists 	(
							select distinct pls1.Lump_Sum_Amount 
							from Program_Lump_Sum_Product_Data pd1 ,program_lump_sums  pls1 
							where 	pls1.Program_ID = #arguments.existingid#
							and 	pls1.Program_Lump_Sum_ID = pd1.Program_Lump_Sum_ID 
							and 	pls1.deleted = 0 
							and 	pd1.deleted =0
							and	cast(pls1.Lump_Sum_Amount AS float) = cast(pls.Lump_Sum_Amount AS float)
						)
		</CFQUERY>
		<cfreturn qGetNotInLumpSumInfo />
	</cffunction>
	
	<cffunction name="GetInLumpSumInfo" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
		<CFQUERY name="qGetInLumpSumInfo" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			select	distinct pls.Lump_Sum_Amount 
			from 	Program_Lump_Sum_Product_Data pd ,program_lump_sums pls 
			where 	pls.Program_ID = '#arguments.currid#'
			and 	pls.deleted = 0
			and 	pd.deleted = 0
			and 	pls.Program_Lump_Sum_ID = pd.Program_Lump_Sum_ID
			and	Exists 	(
							select distinct pls1.Lump_Sum_Amount 
							from  Program_Lump_Sum_Product_Data pd1 ,program_lump_sums  pls1 
							where 	pls1.Program_ID = #arguments.existingid#
							and 	pls1.Program_Lump_Sum_ID = pd1.Program_Lump_Sum_ID 
							and 	pls1.deleted = 0 
							and 	pd1.deleted =0
							and	cast(pls1.Lump_Sum_Amount AS float) = cast(pls.Lump_Sum_Amount AS float)
						)
		</CFQUERY>
		<cfreturn qGetInLumpSumInfo />
	</cffunction>
	
	<!--- COMPONENT LEVEL LUMP SUM DOLLAR AMOUNT CHECK --->
	<cffunction name="GetInCompLumpSumDollar" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
		<cfset var qGetInCompLumpSumDollar = "" />
		<CFQUERY name="qGetInCompLumpSumDollar" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			select	distinct pls.Lump_Sum_Amount 
			from 	program_lump_sums pls 
			where 	pls.Program_ID = '#arguments.currid#'
			and 	pls.deleted = 0
			and	Exists 	(
							select distinct pls1.Lump_Sum_Amount 
							from  program_lump_sums  pls1 
							where 	pls1.Program_ID = '#arguments.existingid#'
							and 	pls1.deleted = 0
							and	cast(pls1.Lump_Sum_Amount AS float) = cast(pls.Lump_Sum_Amount AS float)
						)
		</CFQUERY>
		<cfreturn qGetInCompLumpSumDollar />
	</cffunction>
	
	<!---$$$$$$$$$$$$$$$$$$$$$ end check for program lump sum $$$$$$$$$$$$$$$$$$$$$$$$$--->

	<!---$$$$$$$$$$$$$$$$$$$$$ check for product $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--->
	<!--- product check will consider item and group both from now on --->
	<!--- in terms of group level products, only three discount types are taken into consideration--->
	<!--- fee(lump sum), growth(Component), allowance(Rebate)--->
	<!--- for rebate group level, pricing levels need to be checked --->
	<!--- get product information --->
	<cffunction name="IsProductGroup" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<CFQUERY name="qIsProductGroup" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			select  distinct is_group
			from	contract_products 
			where	contract_main_id = #arguments.currid#
			and		deleted = 0
		</CFQUERY>
		<cfreturn qIsProductGroup />
	</cffunction>

	<!---- group level --->
	<cffunction name="GetNotInProductGroupInfo" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
		<CFQUERY name="qGetNotInProductGroupInfo" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT	Contract_Products.Contract_Products_ID,
					Contract_Products.Pricing_Level_ID, 
					Type_Code_Desc.Type_Code_Desc, 
					Brand.Brand_Name,
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					Contract_Products.Product_Group_Level_ID,
					Contract_Products.Product_Group_ID,
					CASE
						WHEN Contract_Products.Product_Group_Level_ID = 1 THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.UPC
					END As UPC, 
					CASE 
						WHEN Contract_Products.Product_Group_Level_ID = 1 THEN
						''
						WHEN Contract_Products.Product_Group_Level_ID IN (SELECT Product_Group_Level_ID FROM Product_Group_Level WHERE DELETED = 0) THEN
						'Group Product'
						ELSE
						BSA_Foodservice_Items_Master.Item
						END As Item,
					CASE 
						WHEN Contract_Products.Product_Group_Level_ID = 1 THEN
						'All ' + ISNULL(Business_Segment.Business_Unit_Desc, '') + ' Products'
						WHEN Contract_Products.Product_Group_Level_ID IN (SELECT Product_Group_Level_ID FROM Product_Group_Level WHERE DELETED = 0 AND Product_Group_Level_Type = 2) THEN 
						Product_Hierarchy.Product_Hierarchy_Name
						WHEN Contract_Products.Product_Group_Level_ID IN (SELECT Product_Group_Level_ID FROM Product_Group_Level WHERE DELETED = 0 AND Product_Group_Level_Type = 3) THEN 
						Type_Group_Desc.Type_Group_Desc
						WHEN Contract_Products.Product_Group_Level_ID IN (SELECT Product_Group_Level_ID FROM Product_Group_Level WHERE DELETED = 0 AND Product_Group_Level_Type = 4) THEN 
						Class_Code.Class_Code_Desc
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As Description
			FROM    Contract_Products 
			INNER JOIN BSA_Foodservice_Items_Master 
						ON Contract_Products.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID 
			LEFT JOIN Brand 
						ON BSA_Foodservice_Items_Master.Brand_ID = Brand.Brand_ID 
			LEFT JOIN Type_Code_Desc 
						ON BSA_Foodservice_Items_Master.Type_Code_Desc_ID = Type_Code_Desc.Type_Code_Desc_ID 
			LEFT JOIN Business_Segment 
						ON Business_Segment.Deleted = 0
						AND CAST(Business_Segment.Business_Segment_ID as nvarchar(50)) = CAST(Contract_Products.Product_Group_ID as nvarchar(50))
			LEFT JOIN Product_Hierarchy  	
						ON Product_Hierarchy.Deleted = 0 
						AND CAST(Product_Hierarchy.Product_Hierarchy_ID as nvarchar(50)) = CAST(Contract_Products.Product_Group_ID as nvarchar(50))
			LEFT JOIN Type_Group_Desc 	
						ON Type_Group_Desc.Deleted = 0 
						AND CAST(Type_Group_Desc.Type_Group_Desc_ID as nvarchar(50)) = CAST(Contract_Products.Product_Group_ID as nvarchar(50))
			LEFT JOIN Class_Code  
						ON Class_Code.Deleted = 0 
						AND CAST(Class_Code.Class_Code_UUID as nvarchar(50)) = CAST(Contract_Products.Product_Group_ID as nvarchar(50))
			WHERE 	Contract_Products.Deleted = 0 
			AND		Contract_Products.contract_main_id  = #arguments.currid#
			AND		Contract_Products.is_group = 1		
			and Not Exists 
				(
					SELECT	Contract_Products1.Contract_Products_ID,
							Contract_Products1.Pricing_Level_ID, 
							Type_Code_Desc1.Type_Code_Desc, 
							Brand1.Brand_Name,
							BSA_Foodservice_Items_Master1.BSA_Foodservice_Items_Master_ID,
							Contract_Products1.Product_Group_Level_ID,
							Contract_Products1.Product_Group_ID,
							CASE
								WHEN Contract_Products1.Product_Group_Level_ID = 1 THEN
								''
								ELSE
								BSA_Foodservice_Items_Master1.UPC
								END As UPC, 
							CASE 
								WHEN Contract_Products1.Product_Group_Level_ID = 1 THEN
								''
								WHEN Contract_Products1.Product_Group_Level_ID IN (SELECT Product_Group_Level_ID FROM Product_Group_Level WHERE DELETED = 0) THEN
								'Group Product'
								ELSE
								BSA_Foodservice_Items_Master1.Item
								END As Item,
							CASE 
								WHEN Contract_Products1.Product_Group_Level_ID = 1 THEN
								'All ' + ISNULL(Business_Segment1.Business_Unit_Desc, '') + ' Products'
								WHEN Contract_Products1.Product_Group_Level_ID IN (SELECT Product_Group_Level_ID FROM Product_Group_Level WHERE DELETED = 0 AND Product_Group_Level_Type = 2) THEN 
								Product_Hierarchy1.Product_Hierarchy_Name
								WHEN Contract_Products1.Product_Group_Level_ID IN (SELECT Product_Group_Level_ID FROM Product_Group_Level WHERE DELETED = 0 AND Product_Group_Level_Type = 3) THEN 
								Type_Group_Desc1.Type_Group_Desc
								WHEN Contract_Products1.Product_Group_Level_ID IN (SELECT Product_Group_Level_ID FROM Product_Group_Level WHERE DELETED = 0 AND Product_Group_Level_Type = 4) THEN 
								Class_Code1.Class_Code_Desc
								ELSE
								BSA_Foodservice_Items_Master1.Description
								END As Description
					FROM    Contract_Products  Contract_Products1  
					INNER JOIN BSA_Foodservice_Items_Master BSA_Foodservice_Items_Master1 
							ON BSA_Foodservice_Items_Master1.Deleted = 0
							AND	Contract_Products1.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master1.BSA_Foodservice_Items_Master_ID 
					LEFT JOIN Brand Brand1  
							ON 	Brand1.Deleted = 0
							AND	BSA_Foodservice_Items_Master1.Brand_ID = Brand1.Brand_ID 
					LEFT JOIN Type_Code_Desc Type_Code_Desc1  
							ON 	Type_Code_Desc1.Deleted = 0
							AND	BSA_Foodservice_Items_Master1.Type_Code_Desc_ID = Type_Code_Desc1.Type_Code_Desc_ID 
					LEFT JOIN Business_Segment Business_Segment1 
							ON Business_Segment1.Deleted = 0
							AND CAST(Business_Segment1.Business_Segment_ID as nvarchar(50)) = CAST(Contract_Products1.Product_Group_ID as nvarchar(50))
					LEFT JOIN Product_Hierarchy Product_Hierarchy1  
							ON Product_Hierarchy1.Deleted = 0 
							AND CAST(Product_Hierarchy1.Product_Hierarchy_ID as nvarchar(50)) = CAST(Contract_Products1.Product_Group_ID as nvarchar(50))
					LEFT JOIN Type_Group_Desc Type_Group_Desc1 	
							ON Type_Group_Desc1.Deleted = 0 
							AND CAST(Type_Group_Desc1.Type_Group_Desc_ID as nvarchar(50)) = CAST(Contract_Products1.Product_Group_ID as nvarchar(50))
					LEFT JOIN Class_Code Class_Code1  
							ON Class_Code1.Deleted = 0 
							AND CAST(Class_Code1.Class_Code_UUID as nvarchar(50)) = CAST(Contract_Products1.Product_Group_ID as nvarchar(50))
					WHERE 	Contract_Products1.Deleted = 0 
					<!--- same product--->
					AND		Contract_Products.Product_Group_ID = Contract_Products1.Product_Group_ID
					AND		contract_products.product_type_id = contract_products1.product_type_id
					AND		Contract_Products1.contract_main_id  = #arguments.existingid#
					AND		Contract_Products1.is_group = 1
				)

		</CFQUERY>
		<cfreturn qGetNotInProductGroupInfo />
	</cffunction>
	
	<cffunction name="GetInProductGroupInfo" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
		<CFQUERY name="qGetInProductGroupInfo" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT	Contract_Products.Contract_Products_ID,
					Contract_Products.Pricing_Level_ID, 
					Type_Code_Desc.Type_Code_Desc, 
					Brand.Brand_Name,
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					Contract_Products.Product_Group_Level_ID,
					Contract_Products.Product_Group_ID,
					CASE
						WHEN Contract_Products.Product_Group_Level_ID = 1 THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.UPC
					END As UPC, 
					CASE 
						WHEN Contract_Products.Product_Group_Level_ID = 1 THEN
						''
						WHEN Contract_Products.Product_Group_Level_ID IN (SELECT Product_Group_Level_ID FROM Product_Group_Level WHERE DELETED = 0) THEN
						'Group Product'
						ELSE
						BSA_Foodservice_Items_Master.Item
						END As Item,
					CASE 
						WHEN Contract_Products.Product_Group_Level_ID = 1 THEN
						'All ' + ISNULL(Business_Segment.Business_Unit_Desc, '') + ' Products'
						WHEN Contract_Products.Product_Group_Level_ID IN (SELECT Product_Group_Level_ID FROM Product_Group_Level WHERE DELETED = 0 AND Product_Group_Level_Type = 2) THEN 
						Product_Hierarchy.Product_Hierarchy_Name
						WHEN Contract_Products.Product_Group_Level_ID IN (SELECT Product_Group_Level_ID FROM Product_Group_Level WHERE DELETED = 0 AND Product_Group_Level_Type = 3) THEN 
						Type_Group_Desc.Type_Group_Desc
						WHEN Contract_Products.Product_Group_Level_ID IN (SELECT Product_Group_Level_ID FROM Product_Group_Level WHERE DELETED = 0 AND Product_Group_Level_Type = 4) THEN 
						Class_Code.Class_Code_Desc
					ELSE
						BSA_Foodservice_Items_Master.Description
					END As Description
			FROM    Contract_Products 
			INNER JOIN BSA_Foodservice_Items_Master 
						ON 	BSA_Foodservice_Items_Master.Deleted = 0
						AND	Contract_Products.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID 
			LEFT JOIN Brand 
						ON 	Brand.Deleted = 0
						AND	BSA_Foodservice_Items_Master.Brand_ID = Brand.Brand_ID 
			LEFT JOIN Type_Code_Desc 
						ON BSA_Foodservice_Items_Master.Type_Code_Desc_ID = Type_Code_Desc.Type_Code_Desc_ID 
			LEFT JOIN Business_Segment 
						ON Business_Segment.Deleted = 0
						AND CAST(Business_Segment.Business_Segment_ID as nvarchar(50)) = CAST(Contract_Products.Product_Group_ID as nvarchar(50))
			LEFT JOIN Product_Hierarchy  	
						ON Product_Hierarchy.Deleted = 0 
						AND CAST(Product_Hierarchy.Product_Hierarchy_ID as nvarchar(50)) = CAST(Contract_Products.Product_Group_ID as nvarchar(50))
			LEFT JOIN Type_Group_Desc 	
						ON Type_Group_Desc.Deleted = 0 
						AND CAST(Type_Group_Desc.Type_Group_Desc_ID as nvarchar(50)) = CAST(Contract_Products.Product_Group_ID as nvarchar(50))
			LEFT JOIN Class_Code  
						ON Class_Code.Deleted = 0 
						AND CAST(Class_Code.Class_Code_UUID as nvarchar(50)) = CAST(Contract_Products.Product_Group_ID as nvarchar(50))
			
			WHERE 	Contract_Products.Deleted = 0 
			AND		Contract_Products.contract_main_id  = #arguments.currid#
			AND Exists 
				(
					SELECT	Contract_Products1.Contract_Products_ID,
							Contract_Products1.Pricing_Level_ID, 
							Type_Code_Desc1.Type_Code_Desc, 
							Brand1.Brand_Name,
							BSA_Foodservice_Items_Master1.BSA_Foodservice_Items_Master_ID,
							Contract_Products1.Product_Group_Level_ID,
							Contract_Products1.Product_Group_ID,
							CASE
								WHEN Contract_Products1.Product_Group_Level_ID = 1 THEN
								''
								ELSE
								BSA_Foodservice_Items_Master1.UPC
								END As UPC, 
							CASE 
								WHEN Contract_Products1.Product_Group_Level_ID = 1 THEN
								''
								WHEN Contract_Products1.Product_Group_Level_ID IN (SELECT Product_Group_Level_ID FROM Product_Group_Level WHERE DELETED = 0) THEN
								'Group Product'
								ELSE
								BSA_Foodservice_Items_Master1.Item
								END As Item,
							CASE 
								WHEN Contract_Products1.Product_Group_Level_ID = 1 THEN
								'All ' + ISNULL(Business_Segment1.Business_Unit_Desc, '') + ' Products'
								WHEN Contract_Products1.Product_Group_Level_ID IN (SELECT Product_Group_Level_ID FROM Product_Group_Level WHERE DELETED = 0 AND Product_Group_Level_Type = 2) THEN 
								Product_Hierarchy1.Product_Hierarchy_Name
								WHEN Contract_Products1.Product_Group_Level_ID IN (SELECT Product_Group_Level_ID FROM Product_Group_Level WHERE DELETED = 0 AND Product_Group_Level_Type = 3) THEN 
								Type_Group_Desc1.Type_Group_Desc
								WHEN Contract_Products1.Product_Group_Level_ID IN (SELECT Product_Group_Level_ID FROM Product_Group_Level WHERE DELETED = 0 AND Product_Group_Level_Type = 4) THEN 
								Class_Code1.Class_Code_Desc
								ELSE
								BSA_Foodservice_Items_Master1.Description
								END As Description
					FROM    Contract_Products  Contract_Products1  
					INNER JOIN BSA_Foodservice_Items_Master BSA_Foodservice_Items_Master1 
							ON Contract_Products1.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master1.BSA_Foodservice_Items_Master_ID 
					LEFT JOIN Brand Brand1 
							ON 	Brand1.Deleted = 0 
							AND	BSA_Foodservice_Items_Master1.Brand_ID = Brand1.Brand_ID 
					LEFT JOIN Type_Code_Desc Type_Code_Desc1  
							ON 	Type_Code_Desc1.Deleted = 0
							AND	BSA_Foodservice_Items_Master1.Type_Code_Desc_ID = Type_Code_Desc1.Type_Code_Desc_ID 
					LEFT JOIN Business_Segment Business_Segment1 
							ON Business_Segment1.Deleted = 0
							AND CAST(Business_Segment1.Business_Segment_ID as nvarchar(50)) = CAST(Contract_Products1.Product_Group_ID as nvarchar(50))
					LEFT JOIN Product_Hierarchy Product_Hierarchy1  
							ON Product_Hierarchy1.Deleted = 0 
							AND CAST(Product_Hierarchy1.Product_Hierarchy_ID as nvarchar(50)) = CAST(Contract_Products1.Product_Group_ID as nvarchar(50))
					LEFT JOIN Type_Group_Desc Type_Group_Desc1 	
							ON Type_Group_Desc1.Deleted = 0 
							AND CAST(Type_Group_Desc1.Type_Group_Desc_ID as nvarchar(50)) = CAST(Contract_Products1.Product_Group_ID as nvarchar(50))
					LEFT JOIN Class_Code Class_Code1 
							ON Class_Code1.Deleted = 0 
							AND CAST(Class_Code1.Class_Code_UUID as nvarchar(50)) = CAST(Contract_Products1.Product_Group_ID as nvarchar(50))
					WHERE 	Contract_Products1.Deleted = 0 
					<!--- same group, same discount type--->
					AND		Contract_Products.Product_Group_ID = Contract_Products1.Product_Group_ID
					AND		contract_products.product_type_id = contract_products1.product_type_id
					AND		Contract_Products1.contract_main_id  = #arguments.existingid#		
				)
		</CFQUERY>
		<cfreturn qGetInProductGroupInfo />
	</cffunction>

	<!--- new group function --->
	<cffunction name="GetNotInProductGroupInfoNew" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
		<CFQUERY name="qGetNotInProductGroupInfoNew" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT DISTINCT BSA_Foodservice_Items_Master_ID, Product_Type_ID, Contract_Main_ID
			FROM  Contract_Products cp 
			WHERE	cp.Contract_Main_ID = '#arguments.currid#'
			and 	cp.deleted = 0
			and		cp.is_group = 1
			AND NOT EXISTS
					(	SELECT 	cp1.BSA_Foodservice_Items_Master_ID
						FROM 	Contract_Products cp1 
						WHERE	cp1.Contract_Main_ID = #arguments.existingid#
						and 	cp.Product_Type_ID = cp1.Product_Type_ID 
						and		cp1.is_group = 1
						and 	cp1.deleted = 0 
						and		cp.BSA_Foodservice_Items_Master_ID = cp1.BSA_Foodservice_Items_Master_ID
					) 

		</CFQUERY>
		<cfreturn qGetNotInProductGroupInfoNew />
	</cffunction>
	
	<cffunction name="GetInProductGroupInfoNew" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
		<CFQUERY name="qGetInProductGroupInfoNew" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT DISTINCT BSA_Foodservice_Items_Master_ID, Product_Type_ID, Contract_Main_ID
			FROM  Contract_Products cp 
			WHERE	cp.Contract_Main_ID = '#arguments.currid#'
			and 	cp.deleted = 0
			and		cp.is_group = 1
			AND EXISTS
					(	SELECT 	cp1.BSA_Foodservice_Items_Master_ID
						FROM 	Contract_Products cp1 
						WHERE	cp1.Contract_Main_ID = #arguments.existingid#
						and 	cp.Product_Type_ID = cp1.Product_Type_ID 
						and		cp1.is_group = 1
						and 	cp1.deleted = 0
						and		cp.BSA_Foodservice_Items_Master_ID = cp1.BSA_Foodservice_Items_Master_ID
					) 

				
		</CFQUERY>
		<cfreturn qGetInProductGroupInfoNew />
	</cffunction>
	
	<!--- item level --->
	<cffunction name="GetNotInProductInfo" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
		<cfargument name="DiscountType" type="numeric" required="false" default ="0"/>
		<CFQUERY name="qGetNotInProductInfo" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT DISTINCT BSA_Foodservice_Items_Master_ID
			FROM  Contract_Products cp 
			WHERE	cp.Contract_Main_ID = '#arguments.currid#'
			AND cp.deleted = 0
			<!--- Ben: D15011 - Removed this due to program not coming up
			                      as duplicate when one program is a group
			                      and the copied program has a product belonging
			                      to that group but is at the item level	
                 and (
					(	cp.Product_Group_ID = CAST(cp.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
						AND cp.Is_Group = 1
					)
            		OR
					(	ISNULL(cp.Product_Group_ID, '') = '' 
						AND cp.Is_Group = 0
					)
				) 
			 End Removed (Ben: D15011) --->
			AND NOT EXISTS
					(	SELECT 	cp1.BSA_Foodservice_Items_Master_ID
						FROM 	Contract_Products cp1 
						<!--- If checking for Components in the various discount types --->
						<CFIF arguments.DiscountType EQ 1>
						INNER JOIN Program_Fixed_Component pfc 
						ON cp1.Contract_Main_ID = pfc.Program_ID
						AND pfc.Program_Fixed_Component_Name_ID = #GetFixedPriceComponent(arguments.currid, arguments.existingid).Program_Fixed_Component_Name_ID#
						AND pfc.Deleted = 0
						</CFIF>
						<CFIF arguments.DiscountType EQ 2>
						INNER JOIN Program_Rebates_Component prc 
						ON cp1.Contract_Main_ID = prc.Program_ID
						AND prc.Program_Rebates_Component_Name_ID = #GetRebateComponent(arguments.currid, arguments.existingid).Program_Rebates_Component_Name_ID#
						AND prc.Deleted = 0
						</CFIF>
						<CFIF arguments.DiscountType EQ 3>
						INNER JOIN Program_Lump_Sums pl 
						ON cp1.Contract_Main_ID = pl.Program_ID
						AND pl.Program_Lump_Sum_Name_ID = #GetLumpsumComponent(arguments.currid, arguments.existingid).Program_Lump_Sum_Name_ID#
						AND pl.Deleted = 0
						</CFIF>
						<CFIF arguments.DiscountType EQ 4>
						INNER JOIN Program_Growth_Components pgc 
						ON cp1.Contract_Main_ID = pgc.Program_ID
						AND pgc.Program_Growth_Components_Name_ID = #GetGrowthComponent(arguments.currid, arguments.existingid).Program_Growth_Components_Name_ID#
						AND pgc.Deleted = 0
						</CFIF>
						<CFIF arguments.DiscountType EQ 8>
						INNER JOIN Program_OffInvoice_Component poc 
						ON cp1.Contract_Main_ID = poc.Program_ID
						AND poc.Program_OffInvoice_Component_Name_ID = #GetOffInvoicePriceComponent(arguments.currid, arguments.existingid).Program_OffInvoice_Component_Name_ID#
						AND poc.Deleted = 0
						</CFIF>
						WHERE	cp1.Contract_Main_ID = #arguments.existingid#
						<CFIF dupTemplateManager.requireDiscountTypeCheck()>
						AND 	cp.Product_Type_ID = cp1.Product_Type_ID
						</CFIF>
						<!--- Ben: D15011 - Removed this due to program not coming up
			                      as duplicate when one program is a group
			                      and the copied program has a product belonging
			                      to that group but is at the item level	 
						     and (
								(	cp1.Product_Group_ID = CAST(cp1.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
									AND cp1.Is_Group = 1
								)
								OR

								(	ISNULL(cp1.Product_Group_ID, '') = '' 
									AND cp1.Is_Group = 0
								)
							)
						and	cp.is_group = cp1.is_group
						<CFIF dupTemplateManager.requireDiscountTypeCheck()>
						AND	( 
								cp1.is_group = 0	
							  	or ( 	cp1.is_group = 1 
									AND cp1.product_type_id != 2 )
								or (	cp1.is_group = 1
									AND 	cp1.product_type_id = 2 
									AND	cp1.product_group_level_id =  cp.product_group_level_id 
									AND 	cp1.product_group_id = cp.product_group_id 
									AND 	cp1.pricing_level_id = cp.pricing_level_id )
									
							)
						</CFIF> End Removed (Ben: D15011) --->
						AND cp1.deleted = 0 
						AND cp.BSA_Foodservice_Items_Master_ID = cp1.BSA_Foodservice_Items_Master_ID
					) 
		</CFQUERY>
		<cfreturn qGetNotInProductInfo />
	</cffunction>
	
	<cffunction name="GetInProductInfo" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
		<cfargument name="DiscountType" type="numeric" required="false" default ="0"/>
		
		<CFQUERY name="qGetInProductInfo" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT DISTINCT BSA_Foodservice_Items_Master_ID
			FROM  Contract_Products cp 
			WHERE	cp.Contract_Main_ID = '#arguments.currid#'
			AND 	cp.deleted = 0
			
            <!--- 	Ben: D15011 - Removed this due to program not coming up
			                      as duplicate when one program is a group
			                      and the copied program has a product belonging
			                      to that group but is at the item level		
               and (
					(	cp.Product_Group_ID = CAST(cp.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
						AND cp.Is_Group = 1
					)
					OR
					(	ISNULL(cp.Product_Group_ID, '') = '' 
						AND cp.Is_Group = 0
					)
				) End Removed (Ben: D15011) --->
			AND EXISTS
				(	    SELECT 	DISTINCT cp1.BSA_Foodservice_Items_Master_ID
						FROM 	Contract_Products cp1
						<!--- If checking for Components in the various discount types --->
						<CFIF arguments.DiscountType EQ 1>
						INNER JOIN Program_Fixed_Component pfc 
						ON cp1.Contract_Main_ID = pfc.Program_ID
						AND pfc.Program_Fixed_Component_Name_ID = #GetFixedPriceComponent(arguments.currid, arguments.existingid).Program_Fixed_Component_Name_ID#
						AND pfc.Deleted = 0
						</CFIF>
						<CFIF arguments.DiscountType EQ 2>
						INNER JOIN Program_Rebates_Component prc 
						ON cp1.Contract_Main_ID = prc.Program_ID
						AND prc.Program_Rebates_Component_Name_ID = #GetRebateComponent(arguments.currid, arguments.existingid).Program_Rebates_Component_Name_ID#
						AND prc.Deleted = 0
						</CFIF>
						<CFIF arguments.DiscountType EQ 3>
						INNER JOIN Program_Lump_Sums pl 
						ON cp1.Contract_Main_ID = pl.Program_ID
						AND pl.Program_Lump_Sum_Name_ID = #GetLumpsumComponent(arguments.currid, arguments.existingid).Program_Lump_Sum_Name_ID#
						AND pl.Deleted = 0
						</CFIF>
						<CFIF arguments.DiscountType EQ 8>
						INNER JOIN Program_OffInvoice_Component poc 
						ON cp1.Contract_Main_ID = poc.Program_ID
						AND poc.Program_OffInvoice_Component_Name_ID = #GetOffInvoicePriceComponent(arguments.currid, arguments.existingid).Program_OffInvoice_Component_Name_ID#
						AND poc.Deleted = 0
						</CFIF>
						WHERE	cp1.Contract_Main_ID = #arguments.existingid#
						<CFIF dupTemplateManager.requireDiscountTypeCheck() AND arguments.DiscountType eq 0>
						AND	cp.Product_Type_ID = cp1.Product_Type_ID 
						</CFIF>
						<!--- Ben: D15011 - Removed this due to program not coming up
			                      as duplicate when one program is a group
			                      and the copied program has a product belonging
			                      to that group but is at the item level
						and	cp.is_group = cp1.is_group
						and (
								(	cp1.Product_Group_ID = CAST(cp1.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
									AND cp1.Is_Group = 1
								)
								OR
								(	ISNULL(cp1.Product_Group_ID, '') = '' 
									AND cp1.Is_Group = 0
								)
							)
						 
						<CFIF dupTemplateManager.requireDiscountTypeCheck()>
						AND	( 
								cp1.is_group = 0	
							  	or ( 	cp1.is_group = 1 
										AND cp1.product_type_id != 2 
									)
								or (	cp1.is_group = 1
										AND cp1.product_type_id = 2 
										AND	cp1.product_group_level_id =  cp.product_group_level_id 
										AND cp1.product_group_id = cp.product_group_id 
										AND cp1.pricing_level_id = cp.pricing_level_id 
									)
							)
						</CFIF>
						End Removed (Ben: D15011) --->
						AND 	cp1.deleted = 0 
						AND		cp.BSA_Foodservice_Items_Master_ID = cp1.BSA_Foodservice_Items_Master_ID
				) 
				AND EXISTS
				(
				
				SELECT 	DISTINCT cp3.BSA_Foodservice_Items_Master_ID 
						FROM 	Contract_Products cp3
					 	LEFT JOIN Program_Fixed_Price_Product_Data PFPD1
						ON cp3.Contract_Main_ID = PFPD1.Program_ID
						AND cp3.Product_Type_ID = 1
						AND PFPD1.Deleted = 0
					WHERE	cp3.Contract_Main_ID = '#arguments.currid#'
					AND CAST(PFPD1.Fixed_Price_Value AS FLOAT) <> 0
					
					UNION					
					SELECT 	DISTINCT cp4.BSA_Foodservice_Items_Master_ID 
											FROM 	Contract_Products cp4
											LEFT JOIN Program_Rebates_Product_Data PRPD1
											ON cp4.Contract_Main_ID = PRPD1.Program_ID
											LEFT JOIN Program_Rebates_Component_Data PRCD1 
											ON PRCD1.Program_Rebates_Product_Data_ID = PRPD1.Program_Rebates_Product_Data_ID
											AND cp4.Product_Type_ID = 2
											AND PRCD1.Deleted = 0 
											AND PRPD1.Deleted = 0  
										WHERE	cp4.Contract_Main_ID = '#arguments.currid#'
										 AND CAST(PRCD1.Rate AS FLOAT) <> 0
					UNION					
					SELECT 	DISTINCT cp5.BSA_Foodservice_Items_Master_ID 
											FROM 	Contract_Products cp5
											
											LEFT JOIN Program_Lump_Sums PLS1 
											ON cp5.Contract_Main_ID = PLS1.Program_ID
											LEFT JOIN Program_Lump_Sum_Product_Data PLSPD1
											ON PLSPD1.Program_Lump_Sum_ID = PLS1.Program_Lump_Sum_ID
											AND cp5.Product_Type_ID = 3
											AND PLS1.Deleted = 0
											AND PLSPD1.Deleted = 0  
										WHERE	cp5.Contract_Main_ID = '#arguments.currid#'
										AND CAST(PLS1.Lump_Sum_Amount AS FLOAT) <> 0 
				)
		</CFQUERY>
		<cfreturn qGetInProductInfo />
	</cffunction>
	<!---$$$$$$$$$$$$$$$$$$$$$$$$ end check for product $$$$$$$$$$$$$$$$$$$$$$$$$$$$$--->
	<!--- Get Component ID's for the various discount types --->
	<cffunction name="GetFixedPriceComponent" access="public" returntype="query">
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
			<CFQUERY name="qGetFixedPriceComponent" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
				SELECT DISTINCT pfc1.Program_Fixed_Component_Name_ID
				FROM Program_Fixed_Component pfc1  INNER JOIN Program_Fixed_Component pfc2 
				ON pfc1.Program_Fixed_Component_Name_ID = pfc2.Program_Fixed_Component_Name_ID
				WHERE pfc1.Program_ID = '#arguments.currid#'
				AND pfc2.Program_ID = '#arguments.existingid#'
				AND pfc1.Deleted = 0
				AND pfc2.Deleted = 0
			</CFQUERY>
			<cfreturn qGetFixedPriceComponent />
	</cffunction>

	<cffunction name="GetRebateComponent" access="public" returntype="query">
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
			<CFQUERY name="qGetRebateComponent" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
				SELECT DISTINCT prc1.Program_Rebates_Component_Name_ID
				FROM Program_Rebates_Component prc1  INNER JOIN Program_Rebates_Component prc2 
				ON prc1.Program_Rebates_Component_Name_ID = prc2.Program_Rebates_Component_Name_ID
				WHERE prc1.Program_ID = '#arguments.currid#'
				AND prc2.Program_ID = '#arguments.existingid#'
				AND prc1.Deleted = 0
				AND prc2.Deleted = 0
			</CFQUERY>
			<cfreturn qGetRebateComponent />
	</cffunction>

	<cffunction name="GetLumpSumComponent" access="public" returntype="query">
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
			<CFQUERY name="qGetLumpSumComponent" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
				SELECT DISTINCT pls1.Program_Lump_Sum_Name_ID
				FROM Program_Lump_Sums pls1  INNER JOIN Program_Lump_Sums pls2 
				ON pls1.Program_Lump_Sum_Name_ID = pls2.Program_Lump_Sum_Name_ID 
				WHERE pls1.Program_ID = '#arguments.currid#'
				AND pls2.Program_ID = '#arguments.existingid#'
				AND pls1.Deleted = 0
				AND pls2.Deleted = 0
			</CFQUERY>
			<cfreturn qGetLumpSumComponent />
	</cffunction>

	<cffunction name="GetGrowthComponent" access="public" returntype="query">
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
			<CFQUERY name="qGetGrowthComponent" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
				SELECT DISTINCT pgc1.Program_Growth_Components_Name_ID
				FROM Program_Growth_Components pgc1  INNER JOIN Program_Growth_Components pgc2 
				ON pgc1.Program_Growth_Components_Name_ID = pgc2.Program_Growth_Components_Name_ID 
				WHERE pgc1.Program_ID = '#arguments.currid#'
				AND pgc2.Program_ID = '#arguments.existingid#'
				AND		pgc1.Deleted = 0
				AND		pgc2.Deleted = 0
			</CFQUERY>
			<cfreturn qGetGrowthComponent />
	</cffunction>

	<cffunction name="GetOffInvoicePriceComponent" access="public" returntype="query">
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
			<CFQUERY name="qGetOffInvoicePriceComponent" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
				SELECT DISTINCT poc1.Program_OffInvoice_Component_Name_ID
				FROM Program_OffInvoice_Component poc1  INNER JOIN Program_OffInvoice_Component poc2 
				ON poc1.Program_OffInvoice_Component_Name_ID = poc2.Program_OffInvoice_Component_Name_ID 
				WHERE poc1.Program_ID = '#arguments.currid#'
				AND poc2.Program_ID = '#arguments.existingid#'
				AND		poc1.Deleted = 0
				AND		poc2.Deleted = 0
			</CFQUERY>
			<cfreturn qGetOffInvoicePriceComponent />
	</cffunction>

	<!--- get current program's discount types (Since Lumpsum can exist without products, check the Program_Lump_Sums table --->
	<cffunction name="GetDiscountTypes" 	access="public" returntype="query" >
		<CFQUERY name="qGetCurrDiscountTypes" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT 	distinct Product_Type_ID
			FROM 	contract_products 
			WHERE 	contract_main_id = #this.getComparedProgramID()#
			AND 	deleted = 0
			UNION
			SELECT distinct '3' As Product_Type_ID
			FROM program_lump_sums 
			WHERE 	program_id = #this.getComparedProgramID()#
			AND 	deleted = 0
			ORDER BY Product_Type_ID
		</CFQUERY>
		<cfreturn qGetCurrDiscountTypes />
	</cffunction>


		<!--- get all the discount types --->
	<cffunction name="GetAllDiscountTypes" 	access="public" returntype="query" >
		<CFQUERY name="qGetAllCurrDiscountTypes" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT Discount_Type_ID
			FROM Discount_type 
			WHERE deleted = 0
		</CFQUERY>
		<cfreturn qGetAllCurrDiscountTypes />
	</cffunction>
	
	<!---$$$$$$$$$$$$$$$$$$$$$$$$ check for rates information ---->
	<!--- get product's fix rate information --->
	<!--- fix rate --->
	<cffunction name="GetNotInProductFixedRates" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
		<cfargument name="IscomponentChecked" type="boolean" required="false" default="0" />
		<cfargument name="ComponentNum" type="numeric" required="false"/>
		<CFQUERY name="qGetNotInProductFixedRates" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			select distinct pr.Fixed_Price_Value, pr.Contract_Products_ID
			from 	Program_Fixed_Price_Product_Data pr ,contract_products cp ,
					BSA_Foodservice_Items_Master cfm 
			where	pr.Contract_Products_ID = cp.Contract_Products_ID
			and 	cp.contract_main_id = '#arguments.currid#'
			and 	cp.BSA_Foodservice_Items_Master_ID = cfm.BSA_Foodservice_Items_Master_ID
				<!--- If checking for Components --->
			<cfif arguments.IscomponentChecked eq 1>
			and		pr.Program_Fixed_Component_ID =
						(select distinct Program_Fixed_Component_ID
						 from Program_Fixed_Component
						 where Program_Fixed_Component_Name_ID = #ComponentNum#	
						 and program_id =  '#arguments.currid#'
						 and deleted = 0)
			</cfif>
			and (
					(	cp.Product_Group_ID = CAST(cp.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
						AND cp.Is_Group = 1
					)
					OR
					<!------ Product ----->
					(	ISNULL(cp.Product_Group_ID, '') = '' 
						AND cp.Is_Group = 0
					)
				)			
			and 	pr.deleted = 0 and cp.deleted =0 and cfm.deleted = 0
			and NOT EXISTS
				(	select 	pr1.Fixed_Price_Value
					from 	Program_Fixed_Price_Product_Data pr1 ,
							contract_products cp1,BSA_Foodservice_Items_Master cfm1 
					where 	pr1.Contract_Products_ID = cp1.Contract_Products_ID 
					and 	cp1.contract_main_id = #arguments.existingid#
					and 	cp1.BSA_Foodservice_Items_Master_ID =    cfm1.BSA_Foodservice_Items_Master_ID 
					and 	pr1.Unit_Of_Measure_ID = pr.Unit_Of_Measure_ID
    				and (
							(	cp1.Product_Group_ID = CAST(cp1.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
								AND cp1.Is_Group = 1
							)
							OR
							<!------ Product ----->
							(	ISNULL(cp1.Product_Group_ID, '') = '' 
								AND cp1.Is_Group = 0
							)
						)				
					and		cfm.BSA_Foodservice_Items_Master_ID = cfm1.BSA_Foodservice_Items_Master_ID
					and 	pr1.deleted = 0 
					and 	cp1.deleted =0
					and		pr.Fixed_Price_Value = pr1.Fixed_Price_Value	
				)
		</CFQUERY>
		<cfreturn qGetNotInProductFixedRates />
	</cffunction>
	
	<cffunction name="GetInProductFixedRates" 	access="public" returntype="query">
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
		<cfargument name="IscomponentChecked" type="boolean" required="false" default="0" />
		<cfargument name="ComponentNum" type="numeric" required="false"/>
		<CFQUERY name="qGetInProductFixedRates" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			select distinct pr.Fixed_Price_Value, pr.Contract_Products_ID
			from 	Program_Fixed_Price_Product_Data pr ,contract_products cp ,
					BSA_Foodservice_Items_Master cfm 
			where	pr.Contract_Products_ID = cp.Contract_Products_ID
			and 	cp.contract_main_id = '#arguments.currid#'
			and 	cp.BSA_Foodservice_Items_Master_ID = cfm.BSA_Foodservice_Items_Master_ID
			<!--- If checking for Components --->
			<cfif arguments.IscomponentChecked eq 1>
			and exists
				(SELECT DISTINCT Program_Fixed_Component_ID
				 FROM Program_Fixed_Component 
				 WHERE pr.Program_Fixed_Component_ID = Program_Fixed_Component.Program_Fixed_Component_ID
				 AND Program_Fixed_Component_Name_ID = #ComponentNum#
				 AND program_id =  '#arguments.currid#'			
				 AND DELETED = 0
				)
			</cfif>		
			and pr.deleted = 0 and cp.deleted =0 and cfm.deleted = 0
			and (
					(	cp.Product_Group_ID = CAST(cp.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
						AND cp.Is_Group = 1
					)
					OR
					<!------ Product ----->
					(	ISNULL(cp.Product_Group_ID, '') = '' 
						AND cp.Is_Group = 0
					)
				)
			and exists
				(	select 	pr1.Fixed_Price_Value
					from 	Program_Fixed_Price_Product_Data pr1 ,
							contract_products cp1 ,BSA_Foodservice_Items_Master cfm1 
					where 	pr1.Contract_Products_ID = cp1.Contract_Products_ID
					and 	cp1.contract_main_id = #arguments.existingid# 
					and 	pr1.Unit_Of_Measure_ID = pr.Unit_Of_Measure_ID 
					and 	cp1.BSA_Foodservice_Items_Master_ID =    cfm1.BSA_Foodservice_Items_Master_ID
    				and		cfm.BSA_Foodservice_Items_Master_ID = cfm1.BSA_Foodservice_Items_Master_ID
					and 	pr1.deleted = 0 
					and 	cp1.deleted =0
					and (
							(	cp1.Product_Group_ID = CAST(cp1.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
								AND cp1.Is_Group = 1
							)
							OR
							<!------ Product ----->
							(	ISNULL(cp1.Product_Group_ID, '') = '' 
								AND cp1.Is_Group = 0
							)
						)
					and		pr.Fixed_Price_Value = pr1.Fixed_Price_Value 
					and 	CAST(pr.Fixed_Price_Value AS FLOAT) <> 0
				)
		</CFQUERY>
		<cfreturn qGetInProductFixedRates />
	</cffunction>
	
	<!--- get product's rebate information --->
	<cffunction name="GetNotInProductRebates" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
		<cfargument name="IscomponentChecked" type="boolean" required="false" default="0" />
		<cfargument name="ComponentNum" type="numeric" required="false"/>
		<CFQUERY name="qGetNotInProductRebates" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT distinct pr.rate, pd.Contract_Products_ID,cfm.BSA_Foodservice_Items_Master_ID,pr.Unit_Of_Measure_ID,pr.Program_Rebates_Component_ID
			into ##tmp_rebate_data
			from Program_Rebates_Component_Data pr ,Program_Rebates_Product_Data pd ,contract_products cp,BSA_Foodservice_Items_Master cfm 
			where 	pd.Contract_Products_ID = cp.Contract_Products_ID
			and 	pr.Program_Rebates_Product_Data_ID = pd.Program_Rebates_Product_Data_ID 
			and 	pd.Program_ID = '#arguments.currid#'			
			and 	cp.BSA_Foodservice_Items_Master_ID = cfm.BSA_Foodservice_Items_Master_ID
			and (
					(	cp.Product_Group_ID = CAST(cp.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
						AND cp.Is_Group = 1
					)
					OR
					<!------ Product ----->
					(	ISNULL(cp.Product_Group_ID, '') = '' 
						AND cp.Is_Group = 0
					)
				)
				<!--- If checking for Components --->
			<cfif arguments.IscomponentChecked eq 1>
			and EXISTS
				(SELECT DISTINCT Program_Rebates_Component_ID
					 FROM Program_Rebates_Component 
					 WHERE Program_Rebates_Component_Name_ID = #ComponentNum#
					 AND Deleted = 0 
					 AND  Program_ID = '#arguments.currid#'
					 AND pr.Program_Rebates_Component_ID = Program_Rebates_Component.Program_Rebates_Component_ID
					)
			</cfif>
			and pr.deleted = 0 and cp.deleted =0 and pd.deleted =0 


			SELECT 	pr1.rate,cfm1.BSA_Foodservice_Items_Master_ID,pr1.Unit_Of_Measure_ID,pr1.Program_Rebates_Component_ID
						into ##tmp_rebate_data_1
						from	Program_Rebates_Component_Data pr1 
								,Program_Rebates_Product_Data pd1             					     
								,contract_products cp1 
								,BSA_Foodservice_Items_Master cfm1 
						where 	pd1.Contract_Products_ID = cp1.Contract_Products_ID
						and 	pr1.Program_Rebates_Product_Data_ID = pd1.Program_Rebates_Product_Data_ID 
						and 	pd1.Program_ID = #arguments.existingid#						
						and 	cp1.BSA_Foodservice_Items_Master_ID = cfm1.BSA_Foodservice_Items_Master_ID
						and 	(
									(	cp1.Product_Group_ID = CAST(cp1.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
										AND cp1.Is_Group = 1
									)
									OR
									<!------ Product ----->
									(	ISNULL(cp1.Product_Group_ID, '') = '' 
										AND cp1.Is_Group = 0
									)
								)
			and pr1.deleted =0  and cp1.deleted = 0 and pd1.deleted = 0 

			SELECT * from ##tmp_rebate_data tbl1
			WHERE NOT EXISTS
						(select * from ##tmp_rebate_data_1 tbl2
						where 	tbl1.BSA_Foodservice_Items_Master_ID =  tbl2.BSA_Foodservice_Items_Master_ID
						and 	tbl1.Unit_Of_Measure_ID = tbl2.Unit_Of_Measure_ID 
						<!--- If checking for Components --->
						<cfif arguments.IscomponentChecked eq 1>
						and exists
						(SELECT DISTINCT Program_Rebates_Component_ID
							 FROM Program_Rebates_Component 
							 WHERE Program_Rebates_Component_Name_ID = #ComponentNum#
							 AND Deleted = 0
							 AND Program_ID = '#arguments.existingid#'
							 AND tbl2.Program_Rebates_Component_ID = Program_Rebates_Component.Program_Rebates_Component_ID
						)
						</cfif>
						and		tbl1.rate = tbl2.rate
						)
			drop table ##tmp_rebate_data
			drop table ##tmp_rebate_data_1
		</CFQUERY>
		<cfreturn qGetNotInProductRebates />
	</cffunction>
	
	<!--- get product's rebate information --->
	<cffunction name="GetInProductRebates" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
		<cfargument name="IscomponentChecked" type="boolean" required="false" default="0" />
		<cfargument name="ComponentNum" type="numeric" required="false"/>
		<CFQUERY name="qGetInProductRebates" datasource="#application.datasource#">
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
				SELECT	prpd.Program_Rebates_Product_Data_ID,
							cp.Contract_Products_ID,
							cp.BSA_Foodservice_Items_Master_ID,
							prc.program_rebates_component_name_ID
					INTO ##tmp_prod
					FROM	Program_Rebates_Product_Data prpd ,
							Contract_Products cp ,
							program_rebates_component prc 
					WHERE 	prpd.contract_products_id = cp.contract_products_id
					AND		prc.Program_ID = prpd.Program_ID
					AND		prpd.Program_ID = '#arguments.currid#'
					AND		prpd.Deleted = 0
					AND		prc.deleted = 0
					AND		cp.Deleted = 0
					AND 
						(	(	cp.Product_Group_ID = CAST(cp.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
								AND cp.Is_Group = 1
							)
							OR ( 	ISNULL(cp.Product_Group_ID, '') = '' 
									AND cp.Is_Group = 0
						  	   )
						)

				SELECT	Program_Rebates_Component_ID, 
							Program_Rebates_Product_Data_ID,
							Rate
						INTO ##tmp_rate
						FROM 	Program_Rebates_Component_Data  
						WHERE EXISTS(
									select 	Program_Rebates_Component_ID 
									from 	Program_Rebates_Component 
									where 	program_id = '#arguments.currid#' and deleted = 0
									<!--- If checking for Components --->
									<cfif arguments.IscomponentChecked eq 1>
									and   program_rebates_component_name_ID = #ComponentNum#
									</cfif>
									and Program_Rebates_Component_Data.program_rebates_component_ID = Program_Rebates_Component.Program_Rebates_Component_ID
								 )
						AND 	deleted = 0

				SELECT 	prpd.Program_Rebates_Product_Data_ID,
						cp.Contract_Products_ID,
						cp.BSA_Foodservice_Items_Master_ID,
						prc.program_rebates_component_name_ID
						INTO ##tmp_prod_1
						FROM 	Program_Rebates_Product_Data prpd ,
								Contract_Products cp ,
								program_rebates_component prc 
						WHERE 	prpd.contract_products_id = cp.contract_products_id
						AND		prc.Program_ID = prpd.Program_ID
						AND		prpd.Program_ID = #arguments.existingid#
						AND		prpd.Deleted = 0
						AND		prc.deleted = 0
						AND		cp.Deleted = 0
						AND 
							(	(	cp.Product_Group_ID = CAST(cp.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
									AND cp.Is_Group = 1
								)
								OR	(	ISNULL(cp.Product_Group_ID, '') = '' 
								AND cp.Is_Group = 0
							)
						)

				SELECT 	Program_Rebates_Component_ID, 
							Program_Rebates_Product_Data_ID,
							Rate
						INTO ##tmp_rate_1
						FROM  	Program_Rebates_Component_Data  
						WHERE EXISTS
								(
								select 	Program_Rebates_Component_ID 
								from 	Program_Rebates_Component  
								where 	program_id = #arguments.existingid# and deleted = 0
								<!--- If checking for Components --->
								<cfif arguments.IscomponentChecked eq 1>
								and   program_rebates_component_name_ID = #ComponentNum#
								</cfif>
								and Program_Rebates_Component_Data.program_rebates_component_ID = Program_Rebates_Component.Program_Rebates_Component_ID
								)
					AND 	deleted = 0


			SELECT rebateProducts.contract_products_id, rebateProducts.program_rebates_component_name_id,rebateProducts.BSA_Foodservice_Items_Master_ID, rebateCompRate.rate
			FROM ##tmp_prod rebateProducts,##tmp_rate rebateCompRate
			WHERE rebateProducts.Program_Rebates_Product_Data_ID = rebateCompRate.Program_Rebates_Product_Data_ID
			AND   exists
					(
					select existingRebateProducts.contract_products_id, existingRebateProducts.program_rebates_component_name_ID,existingRebateProducts.BSA_Foodservice_Items_Master_ID, existingRebateCompRate.rate
					from ##tmp_prod_1 existingRebateProducts,##tmp_rate_1 existingRebateCompRate
					where existingRebateProducts.Program_Rebates_Product_Data_ID = existingRebateCompRate.Program_Rebates_Product_Data_ID
					<!--- If checking for Components --->
					<cfif arguments.IscomponentChecked eq 1>
					and   existingRebateProducts.program_rebates_component_name_ID = rebateProducts.program_rebates_component_name_ID
					</cfif>
					and   existingRebateProducts.BSA_Foodservice_Items_Master_ID = rebateProducts.BSA_Foodservice_Items_Master_ID
					and   existingRebateCompRate.rate = rebateCompRate.rate
					and   CAST(rebateCompRate.rate AS FLOAT) <> 0
					)
			DROP TABLE  ##tmp_prod
			DROP TABLE  ##tmp_rate
			DROP TABLE  ##tmp_prod_1
			DROP TABLE  ##tmp_rate_1
		</CFQUERY>
		<cfreturn qGetInProductRebates />
	</cffunction>
	
	<!--- get program's lump sum information --->
	<cffunction name="GetNotInLumSum" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" 	type="string" required="true" />
		<CFQUERY name="qGetNotInLumSum" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			select	distinct pls.Lump_Sum_Amount 
			from 	Program_Lump_Sum_Product_Data pd ,program_lump_sums pls 
			where 	pls.Program_ID = '#arguments.currid#'
			and 	pls.deleted = 0
			and 	pd.deleted = 0
			and 	pls.Program_Lump_Sum_ID = pd.Program_Lump_Sum_ID
			and	Not Exists 	(
							select distinct pls1.Lump_Sum_Amount 
							from Program_Lump_Sum_Product_Data pd1 ,program_lump_sums  pls1 
							where 	pls1.Program_ID = #arguments.existingid#
							and 	pls1.Program_Lump_Sum_ID = pd1.Program_Lump_Sum_ID 
							and 	pls1.deleted = 0 
							and 	pd1.deleted =0
							and		cast(pls1.Lump_Sum_Amount AS float) = cast(pls.Lump_Sum_Amount AS float)
							)
		</CFQUERY>
		<cfreturn qGetNotInLumSum />
	</cffunction>

	<cffunction name="GetInLumSum" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
		<CFQUERY name="qGetInLumSum" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			select	distinct pls.Lump_Sum_Amount 
			from 	Program_Lump_Sum_Product_Data pd ,program_lump_sums pls 
			where 	pls.Program_ID = '#arguments.currid#'
			and 	pls.deleted = 0
			and 	pd.deleted = 0
			and 	pls.Program_Lump_Sum_ID = pd.Program_Lump_Sum_ID
			and		Exists 	(
							select distinct pls1.Lump_Sum_Amount 
							from Program_Lump_Sum_Product_Data pd1 ,program_lump_sums  pls1 
							where 	pls1.Program_ID = #arguments.existingid#
							and 	pls1.Program_Lump_Sum_ID = pd1.Program_Lump_Sum_ID 
							and 	pls1.deleted = 0 
							and 	pd1.deleted =0
							and		cast(pls1.Lump_Sum_Amount AS float) = cast(pls.Lump_Sum_Amount AS float)
							and   CAST(pls.Lump_Sum_Amount AS FLOAT) <> 0
							)
		</CFQUERY>
		<cfreturn qGetInLumSum />
	</cffunction>
	
	<!--- function collection for component --->
	<!--- get Growth Component information --->
	<cffunction name="GetGrowthComponents" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="numeric" required="true" />
		<CFQUERY name="qGetGrowthComponents" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			select	pc.Program_Growth_Component_ID
			from 	Program_Growth_Components pc , Program_Growth_Components pc1 
			where 	pc.Program_ID = '#arguments.currid#'
			and 	pc1.Program_ID = #arguments.existingid#
			and 	pc.Tier_Count = pc1.Tier_Count
			and 	pc.Rate_Type = pc1.Rate_Type
			and 	pc.component_uom = pc1.component_uom
			and 	pc1.deleted = 0
		</CFQUERY>
		<cfreturn qGetGrowthComponents />
	</cffunction>

	<!--- get Growth Component's tiers information --->
	<cffunction name="GetGrowthComponentTiers" 	access="public" returntype="query" >
		<cfargument name="cmpid" type="string" required="true" />
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" 	type="numeric" required="true" />		
		<CFQUERY name="qGetGrowthComponentTiers" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			select 	pc.Program_Growth_Component_Tier_ID as tier1, 
					pc1.Program_Growth_Component_Tier_ID as tier2
			from Program_Growth_Component_Tiers pc , 
				 Program_Growth_Component_Tiers pc1 ,
				 Program_Growth_Components pgc  
			where pc.program_id = '#arguments.currid#'
			and pc1.program_id = #arguments.existingid#
			and pc.Tier_Number = pc1.Tier_Number
			and pc.Range_Start = pc1.Range_Start
			and pc.Range_End = pc1.Range_End
			and pc.Growth_Amount = pc1.Growth_Amount
			and pgc.Program_Growth_Component_ID = '#arguments.cmpid#'
        	and pc1.deleted = 0
		</CFQUERY>
		<cfreturn qGetGrowthComponentTiers />
	</cffunction>

	<!--- get product Growth Component rates --->
	<cffunction name="GetNotInProductGrowthComponentRates" 	access="public" returntype="query" >
		<cfargument name="tier1_id" type="string" required="true" />
		<cfargument name="tier2_id" type="string" required="true" />
		<CFQUERY name="qGetNotInProductGrowthComponentRates" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		select distinct pt.Rate, 
						pd.Contract_Products_ID
		from Program_Growth_Component_Product_Data pd , 				 
			 Program_Growth_Component_Product_Tier_Data pt , 
        	 contract_products cp , 
			 BSA_Foodservice_Items_Master cfm 
		where pt.Program_Growth_Component_Product_Data_ID = pt.Program_Growth_Component_Product_Data_ID
		and cp.Contract_Products_ID = pd.Contract_Products_ID
		and cp.BSA_Foodservice_Items_Master_ID = cfm.BSA_Foodservice_Items_Master_ID
		and	(
				(	cp.Product_Group_ID = CAST(cp.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
					AND cp.Is_Group = 1
				)
				OR
				<!------ Product ----->
				(	ISNULL(cp.Product_Group_ID, '') = '' 
					AND cp.Is_Group = 0
				)
			)
		and pt.deleted = 0 
		and pd.deleted =0 
		and cp.deleted =0 
		and cfm.deleted = 0
		and pt.Program_Growth_Component_Tier_ID = '#arguments.tier1_id#'
		and NOT EXISTS
	( 	select pt1.rate
		from Program_Growth_Component_Product_Data pd1 ,
			 Program_Growth_Component_Product_Tier_Data pt1 , 
			 contract_products cp1 ,
			 BSA_Foodservice_Items_Master cfm1 
		where pt1.Program_Growth_Component_Product_Data_ID = pt1.Program_Growth_Component_Product_Data_ID
		and cp1.Contract_Products_ID = pd1.Contract_Products_ID
		and cp1.BSA_Foodservice_Items_Master_ID = cfm1.BSA_Foodservice_Items_Master_ID
		and (
				(	cp1.Product_Group_ID = CAST(cp1.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
					AND cp1.Is_Group = 1
				)
				OR
				<!------ Product ----->
				(	ISNULL(cp1.Product_Group_ID, '') = '' 
					AND cp1.Is_Group = 0
				)
			)
		and cfm1.BSA_Foodservice_Items_Master_ID = cfm.BSA_Foodservice_Items_Master_ID
		and pt.Unit_Of_Measure_ID = pt1.Unit_Of_Measure_ID 
		and pt1.deleted = 0 
		and pd1.deleted =0 
		and cp1.deleted =0 
		and cfm1.deleted = 0
		and pt1.Program_Growth_Component_Tier_ID = '#arguments.tier2_id#'
		and pt.Rate = pt1.Rate
	 )

		</CFQUERY>
		<cfreturn qGetNotInProductGrowthComponentRates />
	</cffunction>

	<cffunction name="GetInProductGrowthComponentRates" 	access="public" returntype="query" >
		<cfargument name="tier1_id" type="string" required="true" />
		<cfargument name="tier2_id" type="string" required="true" />
		<CFQUERY name="qGetInProductGrowthComponentRates" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		select distinct pt.Rate, 
						pd.Contract_Products_ID
		from Program_Growth_Component_Product_Data pd , 				 
			 Program_Growth_Component_Product_Tier_Data pt , 
        	 contract_products cp , 
			 BSA_Foodservice_Items_Master cfm 
		where pt.Program_Growth_Component_Product_Data_ID = pt.Program_Growth_Component_Product_Data_ID
		and cp.Contract_Products_ID = pd.Contract_Products_ID
		and cp.BSA_Foodservice_Items_Master_ID = cfm.BSA_Foodservice_Items_Master_ID
		and	(
				(	cp.Product_Group_ID = CAST(cp.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
					AND cp.Is_Group = 1
				)
				OR
				<!------ Product ----->
				(	ISNULL(cp.Product_Group_ID, '') = '' 
					AND cp.Is_Group = 0
				)
			)
		and pt.deleted = 0 
		and pd.deleted =0 
		and cp.deleted =0 
		and cfm.deleted = 0
		and pt.Program_Growth_Component_Tier_ID = '#arguments.tier1_id#'
		and EXISTS
	( 	select pt1.rate
		from Program_Growth_Component_Product_Data pd1 ,
			 Program_Growth_Component_Product_Tier_Data pt1 , 
			 contract_products cp1 ,
			 BSA_Foodservice_Items_Master cfm1 
		where pt1.Program_Growth_Component_Product_Data_ID = pt1.Program_Growth_Component_Product_Data_ID
		and cp1.Contract_Products_ID = pd1.Contract_Products_ID
		and cp1.BSA_Foodservice_Items_Master_ID = cfm1.BSA_Foodservice_Items_Master_ID
		and	(
				(	cp1.Product_Group_ID = CAST(cp1.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
					AND cp1.Is_Group = 1
				)
				OR
				<!------ Product ----->
				(	ISNULL(cp1.Product_Group_ID, '') = '' 
					AND cp1.Is_Group = 0
				)
			)
		and cfm1.BSA_Foodservice_Items_Master_ID = cfm.BSA_Foodservice_Items_Master_ID
		and pt.Unit_Of_Measure_ID = pt1.Unit_Of_Measure_ID 
		and pt1.deleted = 0 
		and pd1.deleted =0 
		and cp1.deleted =0 
		and cfm1.deleted = 0
		and pt1.Program_Growth_Component_Tier_ID = '#arguments.tier2_id#'
		and pt.Rate = pt1.rate
	 )

		</CFQUERY>
		<cfreturn qGetInProductGrowthComponentRates />
	</cffunction>

	<cffunction name="GetInProductGrowthComponentRates_New" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" 	type="numeric" required="true" />
		<cfargument name="IscomponentChecked" type="boolean" required="false" default="0" />
		<cfargument name="ComponentNum" type="numeric" required="false"/>
		<CFQUERY name="qGetInProductGrowthComponentRates_New" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SELECT DISTINCT 	pgc.Program_ID, 
							pgc.Rate_Type, 
							pgc.Tier_Count, 
							cfm.BSA_Foodservice_Items_Master_ID, 
							pt.Rate, 
							pgct.Tier_Number
		FROM         	Program_Growth_Components pgc  
		INNER JOIN		Program_Growth_Component_Tiers pgct  ON pgc.Program_Growth_Component_ID = pgct.Program_Growth_Component_ID
		INNER JOIN		Program_Growth_Component_Product_Tier_Data pt  ON pgct.Program_Growth_Component_Tier_ID = pt.Program_Growth_Component_Tier_ID 
		INNER JOIN		Program_Growth_Component_Product_Data pd  ON pt.Program_Growth_Component_Product_Data_ID = pd.Program_Growth_Component_Product_Data_ID 
		INNER JOIN		Contract_Products cp  ON pd.Contract_Products_ID = cp.Contract_Products_ID 
		INNER JOIN		BSA_Foodservice_Items_Master cfm  ON cp.BSA_Foodservice_Items_Master_ID = cfm.BSA_Foodservice_Items_Master_ID
		WHERE			(pgc.Program_ID = '#arguments.currid#') 
		<!--- If checking for Components --->
		<cfif arguments.IscomponentChecked eq 1>
		AND EXISTS
								(SELECT DISTINCT pgc1.Program_Growth_Component_Product_Data_ID
								 FROM Program_Growth_Component_Product_Data pgc1 
								 WHERE pgc1.Deleted = 0 
								 AND pt.Program_Growth_Component_Product_Data_ID = pgc1.Program_Growth_Component_Product_Data_ID
								 AND EXISTS
									(SELECT DISTINCT pgc2.Program_Growth_Component_ID
										FROM Program_Growth_Components pgc2 
										WHERE pgc2.program_id =  '#arguments.currid#'
										AND pgc2.Program_Growth_Components_Name_ID = #ComponentNum#
										AND pgc2.DELETED = 0
										AND pgc1.Program_Growth_Component_ID = pgc2.Program_Growth_Component_ID
								 	)
								)
		</cfif>
		AND 			(pt.Deleted = 0) 
		AND 			(pd.Deleted = 0) 
		AND 			(cp.Deleted = 0)
		and				(	
							(	cp.Product_Group_ID = CAST(cp.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
								AND cp.Is_Group = 1
							)
							OR
							<!------ Product ----->
							(	ISNULL(cp.Product_Group_ID, '') = '' 
								AND cp.Is_Group = 0
							)
						)
		AND 			(cfm.Deleted = 0) 
		AND 			(pgct.Deleted = 0) 
		AND 			(pgc.Deleted = 0) 
		AND 			(EXISTS
                          (	SELECT     	pgc1.Program_ID, 
						  				pgc1.Rate_Type, 
										pgc1.Tier_Count, 
										cfm1.BSA_Foodservice_Items_Master_ID, 
										pt1.Rate, pgct1.Tier_Number
							FROM        Program_Growth_Component_Tiers pgct1  
							INNER JOIN	Program_Growth_Components pgc1  ON pgct1.Program_Growth_Component_ID = pgc1.Program_Growth_Component_ID 
							INNER JOIN	Program_Growth_Component_Product_Tier_Data pt1  ON pgct1.Program_Growth_Component_Tier_ID = pt1.Program_Growth_Component_Tier_ID 
							INNER JOIN	Program_Growth_Component_Product_Data pd1  ON pt1.Program_Growth_Component_Product_Data_ID = pd1.Program_Growth_Component_Product_Data_ID 
							INNER JOIN	Contract_Products cp1  ON pd1.Contract_Products_ID = cp1.Contract_Products_ID 
							INNER JOIN	BSA_Foodservice_Items_Master cfm1  ON cp1.BSA_Foodservice_Items_Master_ID = cfm1.BSA_Foodservice_Items_Master_ID
							WHERE     	(pgc1.Program_ID = #arguments.existingid#) 
							<!--- If checking for Components --->
							<cfif arguments.IscomponentChecked eq 1>
							AND EXISTS
								(SELECT DISTINCT Program_Growth_Component_Product_Data_ID
								 FROM Program_Growth_Component_Product_Data pgc3 
								 WHERE Deleted = 0
								 AND pt1.Program_Growth_Component_Product_Data_ID = pgc3.Program_Growth_Component_Product_Data_ID
								 AND EXISTS
									(SELECT DISTINCT Program_Growth_Component_ID
										FROM Program_Growth_Components pgc4 
										WHERE program_id =  '#arguments.existingid#'
										AND Program_Growth_Components_Name_ID = #ComponentNum#
										AND DELETED = 0
										AND pgc3.Program_Growth_Component_ID = pgc4.Program_Growth_Component_ID
									)
								 )
							</cfif>
							AND 		(pt1.Deleted = 0) 
							AND 		(pd1.Deleted = 0) 
							AND 		(cp1.Deleted = 0) 
							and			(
											(	cp1.Product_Group_ID = CAST(cp1.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
												AND cp1.Is_Group = 1
											)
											OR
											<!------ Product ----->
											(	ISNULL(cp1.Product_Group_ID, '') = '' 
												AND cp1.Is_Group = 0
											)
										)
							AND 		(cfm1.Deleted = 0) 
							AND 		(pgct1.Deleted = 0) 
							AND 		(pgc1.Deleted = 0) 
							AND 		(pgct1.Tier_Number = pgct.tier_number) 
							AND 		(pgc1.Rate_Type = pgc.rate_type) 
							AND 		(pgc1.Tier_Count = pgc.tier_count) 
							AND 		(pt1.Rate = pt.Rate) 
							AND 		(cfm1.BSA_Foodservice_Items_Master_ID = cfm.BSA_Foodservice_Items_Master_ID)))
		</CFQUERY>
		<cfreturn qGetInProductGrowthComponentRates_New />
	</cffunction>
	
	<cffunction name="GetNotInProductGrowthComponentRates_New" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" 	type="numeric" required="true" />
		<cfargument name="IscomponentChecked" type="boolean" required="false" default="0" />
		<cfargument name="ComponentNum" type="numeric" required="false"/>
		<CFQUERY name="qGetNotInProductGrowthComponentRates_New" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SELECT DISTINCT 	pgc.Program_ID, 
							pgc.Rate_Type, 
							pgc.Tier_Count, 
							cfm.BSA_Foodservice_Items_Master_ID, 
							pt.Rate, 
							pgct.Tier_Number
		FROM         	Program_Growth_Components pgc 
		INNER JOIN		Program_Growth_Component_Tiers pgct  ON pgc.Program_Growth_Component_ID = pgct.Program_Growth_Component_ID 
		INNER JOIN		Program_Growth_Component_Product_Tier_Data pt  ON pgct.Program_Growth_Component_Tier_ID = pt.Program_Growth_Component_Tier_ID 
		INNER JOIN		Program_Growth_Component_Product_Data pd  ON pt.Program_Growth_Component_Product_Data_ID = pd.Program_Growth_Component_Product_Data_ID 
		INNER JOIN		Contract_Products cp  ON pd.Contract_Products_ID = cp.Contract_Products_ID 
		INNER JOIN		BSA_Foodservice_Items_Master cfm  ON cp.BSA_Foodservice_Items_Master_ID = cfm.BSA_Foodservice_Items_Master_ID
		WHERE			(pgc.Program_ID = #arguments.currid#) 
		<!--- If checking for Components --->
		<cfif arguments.IscomponentChecked eq 1>
		AND EXISTS
		(SELECT DISTINCT Program_Growth_Component_Product_Data_ID
		 FROM Program_Growth_Component_Product_Data pgc5 
		 WHERE Deleted = 0
		 AND pt.Program_Growth_Component_Product_Data_ID =  pgc5.Program_Growth_Component_Product_Data_ID
		AND EXISTS
			(SELECT DISTINCT Program_Growth_Component_ID
				FROM Program_Growth_Components pgc6 
				WHERE program_id =  '#arguments.currid#'
				AND Program_Growth_Components_Name_ID = #ComponentNum#
				AND DELETED = 0
				AND pgc5.Program_Growth_Component_ID = pgc6.Program_Growth_Component_ID
			)
		 )
		</cfif>
		AND 			(pt.Deleted = 0) 
		AND 			(pd.Deleted = 0) 
		AND 			(cp.Deleted = 0)
		and				(	
							(	cp.Product_Group_ID = CAST(cp.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
								AND cp.Is_Group = 1
							)
							OR
							<!------ Product ----->
							(	ISNULL(cp.Product_Group_ID, '') = '' 
								AND cp.Is_Group = 0
							)
						)		
		AND 			(cfm.Deleted = 0) 
		AND 			(pgct.Deleted = 0) 
		AND 			(pgc.Deleted = 0) 
		AND 			(NOT EXISTS
                          (	SELECT     	pgc1.Program_ID, 
						  				pgc1.Rate_Type, 
										pgc1.Tier_Count, 
										cfm1.BSA_Foodservice_Items_Master_ID, 
										pt1.Rate, pgct1.Tier_Number
							FROM        Program_Growth_Component_Tiers pgct1  
							INNER JOIN	Program_Growth_Components pgc1  ON pgct1.Program_Growth_Component_ID = pgc1.Program_Growth_Component_ID 
							INNER JOIN	Program_Growth_Component_Product_Tier_Data pt1  ON pgct1.Program_Growth_Component_Tier_ID = pt1.Program_Growth_Component_Tier_ID 
							INNER JOIN	Program_Growth_Component_Product_Data pd1  ON pt1.Program_Growth_Component_Product_Data_ID = pd1.Program_Growth_Component_Product_Data_ID 
							INNER JOIN	Contract_Products cp1  ON pd1.Contract_Products_ID = cp1.Contract_Products_ID 
							INNER JOIN	BSA_Foodservice_Items_Master cfm1  ON cp1.BSA_Foodservice_Items_Master_ID = cfm1.BSA_Foodservice_Items_Master_ID
							WHERE     	(pgc1.Program_ID = #arguments.existingid#) 
							<!--- If checking for Components --->
							<cfif arguments.IscomponentChecked eq 1>
							AND EXISTS
								(SELECT DISTINCT Program_Growth_Component_Product_Data_ID
								 FROM Program_Growth_Component_Product_Data pgc7 
								 WHERE Deleted = 0
								 AND pt1.Program_Growth_Component_Product_Data_ID = pgc7.Program_Growth_Component_Product_Data_ID 
								 AND EXISTS
									(SELECT DISTINCT Program_Growth_Component_ID
										FROM Program_Growth_Components pgc8 
										WHERE program_id =  '#arguments.existingid#'
										AND Program_Growth_Components_Name_ID = #ComponentNum#
										AND DELETED = 0
										AND pgc7.Program_Growth_Component_ID = pgc8.Program_Growth_Component_ID
									)
								 )
							</cfif>
							AND 		(pt1.Deleted = 0) 
							AND 		(pd1.Deleted = 0) 
							AND 		(cp1.Deleted = 0) 
							and			(
											(	cp1.Product_Group_ID = CAST(cp1.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
												AND cp1.Is_Group = 1
											)
											OR
											<!------ Product ----->
											(	ISNULL(cp1.Product_Group_ID, '') = '' 
												AND cp1.Is_Group = 0
											)
										)
							AND 		(cfm1.Deleted = 0) 
							AND 		(pgct1.Deleted = 0) 
							AND 		(pgc1.Deleted = 0) 
							AND 		(pgct1.Tier_Number = pgct.tier_number) 
							AND 		(pgc1.Rate_Type = pgc.rate_type) 
							AND 		(pgc1.Tier_Count = pgc.tier_count) 
							AND 		(pt1.Rate = pt.Rate) 
							AND 		(cfm1.BSA_Foodservice_Items_Master_ID = cfm.BSA_Foodservice_Items_Master_ID)))
		</CFQUERY>
		<cfreturn qGetNotInProductGrowthComponentRates_New />
	</cffunction>
	<!--- end collection for component --->

	<!--- get product's formula pricing information --->
	<cffunction name="GetNotInProductFormulaPricingRates" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" 	type="string" required="true" />
		<CFQUERY name="qGetNotInProductFormulaPricingRates" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			select	distinct pr.Price, pr.Contract_Product_ID
			from	Program_Formula_Pricing_Rule_Products pr , 
					contract_products cp ,
					Program_Formula_Pricing_Rule_Mapped pm ,
					BSA_Foodservice_Items_Master cfm 
			where pr.Program_ID = '#arguments.currid#'
			and pr.program_id = pm.program_id
			and pr.Contract_Product_ID = cp.Contract_Products_ID
			and cp.BSA_Foodservice_Items_Master_ID = cfm.BSA_Foodservice_Items_Master_ID
			and	(
					(	cp.Product_Group_ID = CAST(cp.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
						AND cp.Is_Group = 1
					)
					OR
					<!------ Product ----->
					(	ISNULL(cp.Product_Group_ID, '') = '' 
						AND cp.Is_Group = 0
					)
				)
			and pr.deleted = 0 
			and cp.deleted =0 
			and cfm.deleted = 0 
			and pm.deleted =0 
			and NOT EXISTS
			(	select pr1.Price 
				from Program_Formula_Pricing_Rule_Products pr1 , 
					 contract_products cp1 ,
					 Program_Formula_Pricing_Rule_Mapped pm1 ,
					 BSA_Foodservice_Items_Master cfm1 
				where pr1.Program_ID = #arguments.existingid#
				and pr1.program_id = pm1.program_id
				and pm1.Formula_Pricing_Rule_ID = pm.Formula_Pricing_Rule_ID
				and pr1.Contract_Product_ID = cp1.Contract_Products_ID 
				and cp1.BSA_Foodservice_Items_Master_ID = cfm1.BSA_Foodservice_Items_Master_ID
				and	(
						(	cp1.Product_Group_ID = CAST(cp1.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
							AND cp1.Is_Group = 1
						)
						OR
						<!------ Product ----->
						(	ISNULL(cp1.Product_Group_ID, '') = '' 
							AND cp1.Is_Group = 0
						)
					)				
				and cfm.BSA_Foodservice_Items_Master_ID =cfm1.BSA_Foodservice_Items_Master_ID
				and pr1.Unit_Of_Measure_ID = pr.Unit_Of_Measure_ID
				and pr1.Product_Overage = pr.Product_Overage
				and pr1.deleted =0 
				and cp1.deleted = 0 
				and cfm1.deleted = 0 
				and pm1.deleted = 0 
				and pr.Price = pr1.Price
			  )
		</CFQUERY>
		<cfreturn qGetNotInProductFormulaPricingRates />
	</cffunction>
	<cffunction name="GetInProductFormulaPricingRates" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
		<CFQUERY name="qGetInProductFormulaPricingRates" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			select	distinct pr.Price, pr.Contract_Product_ID
			from	Program_Formula_Pricing_Rule_Products pr , 
					contract_products cp ,
					Program_Formula_Pricing_Rule_Mapped pm ,
					BSA_Foodservice_Items_Master cfm 
			where pr.Program_ID = '#arguments.currid#'
			and pr.program_id = pm.program_id
			and pr.Contract_Product_ID = cp.Contract_Products_ID
			and cp.BSA_Foodservice_Items_Master_ID = cfm.BSA_Foodservice_Items_Master_ID
			and	(
					(	cp.Product_Group_ID = CAST(cp.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
						AND cp.Is_Group = 1
					)
					OR
					<!------ Product ----->
					(	ISNULL(cp.Product_Group_ID, '') = '' 
						AND cp.Is_Group = 0
					)
				)
			and pr.deleted = 0 
			and cp.deleted =0 
			and cfm.deleted = 0 
			and pm.deleted =0
			and exists
			(	select pr1.Price 
				from Program_Formula_Pricing_Rule_Products pr1 , 
					 contract_products cp1 ,
					 Program_Formula_Pricing_Rule_Mapped pm1 ,
					 BSA_Foodservice_Items_Master cfm1 
				where pr1.Program_ID = #arguments.existingid#
				and pr1.program_id = pm1.program_id
				and pm1.Formula_Pricing_Rule_ID = pm.Formula_Pricing_Rule_ID
				and pr1.Contract_Product_ID = cp1.Contract_Products_ID 
				and cp1.BSA_Foodservice_Items_Master_ID = cfm1.BSA_Foodservice_Items_Master_ID
			   and	(
						(	cp1.Product_Group_ID = CAST(cp1.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
							AND cp1.Is_Group = 1
						)
						OR
						<!------ Product ----->
						(	ISNULL(cp1.Product_Group_ID, '') = '' 
							AND cp1.Is_Group = 0
						)
					)
   				and cfm.BSA_Foodservice_Items_Master_ID =cfm1.BSA_Foodservice_Items_Master_ID
				and pr1.Unit_Of_Measure_ID = pr.Unit_Of_Measure_ID
				and pr1.Product_Overage = pr.Product_Overage
				and pr1.deleted =0 
				and cp1.deleted = 0 
				and cfm1.deleted = 0 
				and pm1.deleted = 0 
				and pr.Price = pr1.Price
			  )
		</CFQUERY>
		<cfreturn qGetInProductFormulaPricingRates />
	</cffunction>
	
	<!--- get product's off invoice information --->
	<cffunction name="GetNotInProductOffInvoiceRates" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
		<cfargument name="IscomponentChecked" type="boolean" required="false" default="0" />
		<cfargument name="ComponentNum" type="numeric" required="false"/>
		<CFQUERY name="qGetNotInProductOffInvoiceRates" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			select	distinct pr.Discount_Amount, pr.Contract_Products_ID
			from 	Program_OffInvoice_Product_Data pr ,
					contract_products cp ,
					BSA_Foodservice_Items_Master cfm 
			where 	cp.contract_main_id = '#arguments.currid#'
			and 	pr.Contract_Products_ID = cp.Contract_Products_ID
			and 	cp.BSA_Foodservice_Items_Master_ID = cfm.BSA_Foodservice_Items_Master_ID
			and		(
						(	cp.Product_Group_ID = CAST(cp.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
							AND cp.Is_Group = 1
						)
						OR
						<!------ Product ----->
						(	ISNULL(cp.Product_Group_ID, '') = '' 
							AND cp.Is_Group = 0
						)
					)
			<!--- If checking for Components --->
			<cfif arguments.IscomponentChecked eq 1>
			and		pr.Program_OffInvoice_Component_ID =
						(select distinct Program_OffInvoice_Component_ID
						 from Program_OffInvoice_Component 
						 where program_id =  '#arguments.currid#'
						 and Program_OffInvoice_Component_Name_ID = #ComponentNum#	
						 and deleted = 0)
			</cfif>
			and 	pr.deleted = 0 
			and 	cp.deleted =0
			and not exists
			(select pr1.Discount_Amount
			 from Program_OffInvoice_Product_Data pr1 , 
				  contract_products cp1 , 
				  BSA_Foodservice_Items_Master cfm1 
			 where cp1.contract_main_id = #arguments.existingid#
			 and pr1.Contract_Products_ID = cp1.Contract_Products_ID 
			 and pr1.UOM = pr.UOM 
			 and pr1.Plus_Minus = pr.Plus_Minus
			 and cp1.BSA_Foodservice_Items_Master_ID = cfm1.BSA_Foodservice_Items_Master_ID
			 and (
					(	cp1.Product_Group_ID = CAST(cp1.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
						AND cp1.Is_Group = 1
					)
					OR
					<!------ Product ----->
					(	ISNULL(cp1.Product_Group_ID, '') = '' 
						AND cp1.Is_Group = 0
					)
				  )		
			 and cfm.BSA_Foodservice_Items_Master_ID = cfm1.BSA_Foodservice_Items_Master_ID
			 and pr1.deleted = 0 
			 and cp1.deleted =0 
			 and pr.Discount_Amount = pr1.Discount_Amount
			 )
		</CFQUERY>
		<cfreturn qGetNotInProductOffInvoiceRates />
	</cffunction>
	
	<cffunction name="GetInProductOffInvoiceRates" 	access="public" returntype="query" >
		<cfargument name="currid" type="string" required="true" />
		<cfargument name="existingid" type="string" required="true" />
		<cfargument name="IscomponentChecked" type="boolean" required="false" default="0" />
		<cfargument name="ComponentNum" type="numeric" required="false"/>
		<CFQUERY name="qGetInProductOffInvoiceRates" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			select	distinct pr.Discount_Amount, pr.Contract_Products_ID
			from 	Program_OffInvoice_Product_Data pr ,
					contract_products cp ,
					BSA_Foodservice_Items_Master cfm 
			where 	cp.contract_main_id = '#arguments.currid#'
			and 	pr.Contract_Products_ID = cp.Contract_Products_ID
			and 	cp.BSA_Foodservice_Items_Master_ID = cfm.BSA_Foodservice_Items_Master_ID
			and		(
						(	cp.Product_Group_ID = CAST(cp.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
							AND cp.Is_Group = 1
						)
						OR
						<!------ Product ----->
						(	ISNULL(cp.Product_Group_ID, '') = '' 
							AND cp.Is_Group = 0
						)
					)
			<!--- If checking for Components --->
			<cfif arguments.IscomponentChecked eq 1>
			and EXISTS
				(SELECT DISTINCT Program_OffInvoice_Component_ID
				 FROM Program_OffInvoice_Component 
				 WHERE program_id =  '#arguments.currid#'
				 AND Program_OffInvoice_Component_Name_ID = #ComponentNum#
				 AND DELETED = 0
				 AND pr.Program_OffInvoice_Component_ID = Program_OffInvoice_Component.Program_OffInvoice_Component_ID
				 )
			</cfif>	
			and 	pr.deleted = 0 
			and 	cp.deleted =0
			and 	pr.Discount_Amount IN 
			(select pr1.Discount_Amount
			 from Program_OffInvoice_Product_Data pr1 , 
				  contract_products cp1 , 
				  BSA_Foodservice_Items_Master cfm1 
			 where cp1.contract_main_id = #arguments.existingid#
			 and pr1.Contract_Products_ID = cp1.Contract_Products_ID 
			 and pr1.UOM = pr.UOM 
			 and pr1.Plus_Minus = pr.Plus_Minus
			 and cp1.BSA_Foodservice_Items_Master_ID = cfm1.BSA_Foodservice_Items_Master_ID
    		  and (
						(	cp1.Product_Group_ID = CAST(cp1.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) 
							AND cp1.Is_Group = 1
						)
						OR
						<!------ Product ----->
						(	ISNULL(cp1.Product_Group_ID, '') = '' 
							AND cp1.Is_Group = 0
						)
					)	
			 and cfm.BSA_Foodservice_Items_Master_ID = cfm1.BSA_Foodservice_Items_Master_ID
			 and pr1.deleted = 0 
			 and cp1.deleted =0 )
		</CFQUERY>
		<cfreturn qGetInProductOffInvoiceRates />
	</cffunction>
	<!---$$$$$$$$$$$$$$$$$$$$$$$$ check for rates information ---->
			
<cffunction name="getDuplicatesByProduct" output="false" returntype="struct">
	
	<cfargument name="ProgramID" default="0" required="true" >
	<cfargument name="DuplicateProgramIDList" default="" required="false" >
	<cfargument name="is_component_checked" default="0" required="true" >
	<cfargument name="is_rate_checked" default="0" required="true" >
	<cfargument name="reportType" default="Level1" required="true" >
	<cfargument name="productID" default="" required="false" >
	<cfargument name="filter_Distributor" default="0" required="false" >
		
	<cfset var duplicates=structNew()>
	<cfset var qDuplicatesByProducts="">
	<cfset var qGetCurrentProgram="">

		<cfquery name="local.qDropTempTable" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_other_pgm') IS NOT NULL
			DROP TABLE ##tmp_other_pgm
			
			IF OBJECT_ID('tempdb..##tmp_existing_fp') IS NOT NULL
			DROP TABLE ##tmp_existing_fp
			
			IF OBJECT_ID('tempdb..##tmp_existing_reb') IS NOT NULL
			DROP TABLE ##tmp_existing_reb
			
			IF OBJECT_ID('tempdb..##tmp_existing_growth') IS NOT NULL
			DROP TABLE ##tmp_existing_growth
			
			IF OBJECT_ID('tempdb..##tmp_cur_cp') IS NOT NULL
			DROP TABLE ##tmp_cur_cp
			
			IF OBJECT_ID('tempdb..##tmp_cur_cp') IS NOT NULL
			DROP TABLE ##tmp_cur_cp
			
			IF OBJECT_ID('tempdb..##tmp_cur_growth') IS NOT NULL
			DROP TABLE ##tmp_cur_growth
		</cfquery>
		
		<cfset useUOM = 0 /> <!--- This need to come from template default ---->
	
		<cfquery name="qDuplicatesByProducts" datasource="#application.datasource#">
			DECLARE @Contract_Main_ID int = #arguments.ProgramID#,
							@UseUOM int = #Val(useUOM)#,
							@Base_Sales_based_on_Prg_Start_Date bit, 
							@Select_Effective_Date_for_Price bit,
							@Price_List_Header_ID uniqueidentifier,
							@Effective_Date_for_Price datetime

			IF OBJECT_ID('tempdb..##tmp_other_pgm') IS NOT NULL
			DROP TABLE ##tmp_other_pgm
		
			SELECT	cm.Contract_Main_ID, cm.Contract_Number, cm.contract_title, cm.contract_start_date, cm.contract_end_date
			INTO	##tmp_other_pgm
			FROM	Contract_Main cm
			WHERE	cm.Contract_Main_ID IN (#arguments.DuplicateProgramIDList#)
			
			<!--------------------- Get current program rates ---------------------->
			IF OBJECT_ID('tempdb..##tmp_cur_cp') IS NOT NULL
			DROP TABLE ##tmp_cur_cp
			SELECT	cp.Contract_Main_ID, cp.BSA_Foodservice_Items_Master_ID, cp.Product_Type_ID, i.Item, i.Description, CAST(i.Net_Weight as float) as Net_Weight, cp.Contract_Products_ID, cm.contract_start_date, cm.contract_end_date
			INTO	##tmp_cur_cp
			FROM	Contract_Products cp
			INNER JOIN BSA_Foodservice_Items_Master i ON i.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
			INNER JOIN Contract_Main CM
			ON CM.Contract_Main_ID = CP.Contract_Main_ID
			WHERE	cp.Contract_Main_ID = @Contract_Main_ID
			AND		cp.Deleted = 0
			AND		cp.Is_Group = 0
			<cfif arguments.productID neq "">
			AND		cp.BSA_Foodservice_Items_Master_ID = '#arguments.productID#'
			</cfif>

	<!--------------------- Get price ---------------------->
		IF OBJECT_ID('tempdb..##tmp_items') IS NOT NULL
		DROP TABLE ##tmp_items
		SELECT	DISTINCT BSA_Foodservice_Items_Master_ID, Item, cp.Description, Net_Weight, CAST(null as decimal(20, 5)) as Price_CS, CAST(null as decimal(20, 5)) as Price_LB,
				imt.ITEM_DEL_BASE_PRICE,
				imt.ITEM_DEL_BASE_PRICE / cp.Net_Weight as ITEM_DEL_BASE_PRICE_LB
		INTO	##tmp_items
		FROM	##tmp_cur_cp cp
		left join ITEM_MARGIN_TARGETS imt
		on		imt.Product_Id = cp.BSA_Foodservice_Items_Master_ID

		IF OBJECT_ID('tempdb..##tmp_distributors') IS NOT NULL
		DROP TABLE ##tmp_distributors
		select	BSA_Foodservice_Customers_ID, cast(cd.program_weight as decimal(10, 4)) as program_weight
		into	##tmp_distributors
		from	Contract_Distributors cd
		where	cd.Contract_Main_ID = @Contract_Main_ID
		and		cd.Deleted = 0
		and		cd.Is_Group = 0

		IF (SELECT Price_List_By_Template FROM _application_settings) = 1
		BEGIN
			SELECT	@Price_List_Header_ID = Margin_Price_List_Header_ID,
					@Base_Sales_based_on_Prg_Start_Date = Base_Sales_based_on_Prg_Start_Date, 
					@Select_Effective_Date_for_Price = Select_Effective_Date_for_Price,
					@Effective_Date_for_Price = CASE WHEN Select_Effective_Date_for_Price = 0 THEN Contract_Start_Date ELSE ISNULL(ISNULL(Price_Protection_Date, Effective_Date_for_Price), Contract_Start_Date) END
			FROM	Contract_Main cm
			INNER JOIN Program_Control_Panel_Options t ON t.ProgramControl_Panel_Options_ID = cm.programType_ID
			WHERE	cm.Contract_Main_ID = @Contract_Main_ID

			<!--- Get price from price_list_detail from template price list --->
			UPDATE	##tmp_items
			SET		Price_CS = CS_FOB_Price, 
					Price_LB = LB_FOB_Price
			FROM ##tmp_items
			INNER JOIN price_list_detail
			ON	price_list_detail.product_id = ##tmp_items.BSA_Foodservice_Items_Master_ID
			AND	price_list_detail.Deleted = 0
			AND	(
				(@Base_Sales_based_on_Prg_Start_Date = 1 AND @Effective_Date_for_Price between price_list_detail.Start_Date and price_list_detail.End_Date)
				OR (@Base_Sales_based_on_Prg_Start_Date = 0 AND price_list_detail.Active_Code = 'A')
				)
			WHERE	price_list_detail.price_list_header_id = @Price_List_Header_ID -- use price list based on template

		END
		ELSE
		BEGIN			

			declare @dist_prog_weight float
			select @dist_prog_weight = sum(program_weight) from ##tmp_distributors
			if isnull(@dist_prog_weight, 0) = 0 set @dist_prog_weight = 1

			<!--- Get distributor weighted price from Gross_Margin/ITEM_MARGIN_TARGETS --->
			UPDATE	##tmp_items
			SET		Price_CS = CS_Price, 
					Price_LB = LB_Price
			FROM ##tmp_items
			inner join (
				SELECT	i.BSA_Foodservice_Items_Master_ID,
						sum(ISNULL(ISNULL(CAST(gm.CS_FOB_Price as decimal(20, 5)), i.ITEM_DEL_BASE_PRICE), 0)* cd.program_weight) / @dist_prog_weight AS CS_Price,
						sum(ISNULL(ISNULL(CAST(gm.LB_FOB_Price as decimal(20, 5)), i.ITEM_DEL_BASE_PRICE_LB), 0)* cd.program_weight) / @dist_prog_weight AS LB_Price
				FROM	##tmp_items i
				inner join ##tmp_distributors cd on 1=1
				left join Gross_Margin gm
				on		gm.Customer_Id = cd.BSA_Foodservice_Customers_ID
				and		gm.Product_id = i.BSA_Foodservice_Items_Master_ID
				group by i.BSA_Foodservice_Items_Master_ID
			) as tmp
			on		tmp.BSA_Foodservice_Items_Master_ID = ##tmp_items.BSA_Foodservice_Items_Master_ID


		END
	
	<!--- Get current program fixed price --->
	IF OBJECT_ID('tempdb..##tmp_cur_fp') IS NOT NULL
	DROP TABLE ##tmp_cur_fp

	SELECT	cp.BSA_Foodservice_Items_Master_ID, cp.Product_Type_ID, cp.Item, cp.Description, 
			c.Program_Fixed_Component_Name_ID, pd.Fixed_Price_Value, pd.Unit_Of_Measure_ID,
			cp.Net_Weight, price.Price_CS, price.Price_LB,
			CAST(0 as decimal(20, 4)) as Price,
			CAST(0 as decimal(20, 4)) as Fixed_Price,
			CAST(0 as decimal(20, 4)) as Program_FP_Rate
			, cp.contract_start_date
			, cp.contract_end_date
	INTO	##tmp_cur_fp
	FROM	##tmp_cur_cp cp
	INNER JOIN ##tmp_items price ON price.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
	INNER JOIN Program_Fixed_Component c on c.Program_ID = cp.Contract_Main_ID AND c.Deleted = 0 
	INNER JOIN Program_Fixed_Price_Product_Data pd 
	ON 		pd.Contract_Products_ID = cp.Contract_Products_ID 
	AND 	pd.Program_Fixed_Component_ID  = c.Program_Fixed_Component_ID
	AND 	pd.Deleted = 0
	AND 	CAST(pd.Fixed_Price_Value AS FLOAT) <> 0
	WHERE	cp.Product_Type_ID = 1		

	<!--- Get current program rebate --->
	IF OBJECT_ID('tempdb..##tmp_cur_reb') IS NOT NULL
	DROP TABLE ##tmp_cur_reb

	SELECT	cp.BSA_Foodservice_Items_Master_ID, cp.Product_Type_ID, cp.Item, cp.Description, 
			c.Program_Rebates_Component_Name_ID, cd.Rate, cd.Unit_Of_Measure_ID,
			cp.Net_Weight, price.Price_CS, price.Price_LB,
			CAST(0 as decimal(20, 4)) as Price,
			CAST(0 as decimal(20, 4)) as Program_Rate
			, cp.contract_start_date
			, cp.contract_end_date			
	INTO	##tmp_cur_reb
	FROM	##tmp_cur_cp cp
	INNER JOIN ##tmp_items price ON price.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
	INNER JOIN Program_Rebates_Component c on c.Program_ID = cp.Contract_Main_ID AND c.Deleted = 0 
	INNER JOIN Program_Rebates_Product_Data pd on pd.Contract_Products_ID = cp.Contract_Products_ID AND pd.Deleted = 0
	INNER JOIN Program_Rebates_Component_Data cd 
	ON		cd.Program_Rebates_Product_Data_ID = pd.Program_Rebates_Product_Data_ID 
	AND		cd.Program_Rebates_Component_ID = c.Program_Rebates_Component_ID 
	AND 	cd.Deleted = 0
	AND 	CAST(cd.Rate AS FLOAT) <> 0
	WHERE	cp.Product_Type_ID = 2
		
	IF OBJECT_ID('tempdb..##tmp_cur_growth') IS NOT NULL
	DROP TABLE ##tmp_cur_growth

	SELECT	cp.BSA_Foodservice_Items_Master_ID, cp.Product_Type_ID, cp.Item, cp.Description, 
			c.Program_Growth_Components_Name_Id, cd.Rate, cd.Unit_Of_Measure_ID,
			cp.Net_Weight, price.Price_CS, price.Price_LB,
			CAST(0 as decimal(20, 4)) as Price,
			CAST(0 as decimal(20, 4)) as Program_Rate
			, cp.contract_start_date
			, cp.contract_end_date
			, ROW_NUMBER() Over (Partition By c.Program_Growth_Component_ID, pd.Program_Growth_Component_Product_Data_ID Order By t.Tier_Number Desc) as Tier_Max
	INTO	##tmp_cur_growth
	FROM	##tmp_cur_cp cp
	INNER JOIN ##tmp_items price ON price.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
	INNER JOIN Program_Growth_Components c on c.Program_ID = cp.Contract_Main_ID AND c.Deleted = 0 
	INNER JOIN Program_Growth_Component_Tiers t on t.Program_Growth_Component_ID = c.Program_Growth_Component_ID AND t.Deleted = 0
	INNER JOIN Program_Growth_Component_Product_Data pd on pd.Contract_Products_ID = cp.Contract_Products_ID AND pd.Deleted = 0	
	INNER JOIN Program_Growth_Component_Product_Tier_Data cd 
	ON		cd.Program_Growth_Component_Product_Data_ID = pd.Program_Growth_Component_Product_Data_ID 
	AND		cd.Program_Growth_Component_Tier_ID = t.Program_Growth_Component_Tier_ID
	AND 	cd.Deleted = 0
	AND 	CAST(cd.Rate AS FLOAT) <> 0
	WHERE	cp.Product_Type_ID = 4

	-- We will consider max growth rate 
	DELETE ##tmp_cur_growth WHERE Tier_Max > 1

	IF ISNULL(@UseUOM, 0) = 0 SELECT @UseUOM = Unit_Of_Measure_ID FROM ##tmp_cur_fp WHERE Unit_Of_Measure_ID IN (1, 2)
	IF ISNULL(@UseUOM, 0) = 0 SELECT @UseUOM = Unit_Of_Measure_ID FROM ##tmp_cur_reb WHERE Unit_Of_Measure_ID IN (1, 2)
	IF ISNULL(@UseUOM, 0) = 0 SELECT @UseUOM = Unit_Of_Measure_ID FROM ##tmp_cur_growth WHERE Unit_Of_Measure_ID IN (1, 2)
	IF ISNULL(@UseUOM, 0) = 0 SET @UseUOM = 2

	<!--- Update fixed price to common UOM --->
	UPDATE	##tmp_cur_fp
	SET		Fixed_Price = CASE 
						WHEN @UseUOM = Unit_Of_Measure_ID THEN Fixed_Price_Value
						WHEN @UseUOM = 1 AND Unit_Of_Measure_ID = 2 THEN Fixed_Price_Value * Net_Weight
						WHEN @UseUOM = 2 AND Unit_Of_Measure_ID = 1 THEN Fixed_Price_Value / Net_Weight
						END,
			Price = CASE @UseUOM WHEN 2 THEN Price_LB ELSE Price_CS END,
			Program_FP_Rate = CASE WHEN Price > Fixed_Price THEN Price - Fixed_Price ELSE 0 END 
	
	UPDATE ##tmp_cur_fp
   	SET Program_FP_Rate = CASE WHEN Price > Fixed_Price THEN Price - Fixed_Price ELSE 0 END 

	<!--- Update rebate to common UOM --->
	UPDATE ##tmp_cur_reb
	SET Price = CASE @UseUOM WHEN 2 THEN Price_LB ELSE Price_CS END

	UPDATE ##tmp_cur_reb
	SET Program_Rate = CASE 
						 WHEN @UseUOM = Unit_Of_Measure_ID THEN Rate
									 WHEN Unit_Of_Measure_ID = 3 THEN cast(Rate as Decimal(20,5)) * 0.01 * Price
									 WHEN @UseUOM = 1 AND Unit_Of_Measure_ID = 2 THEN Rate * Net_Weight
									 WHEN @UseUOM = 2 AND Unit_Of_Measure_ID = 1 THEN Rate / Net_Weight
									 END
			
	<!--- Update growth to common UOM --->
	UPDATE ##tmp_cur_growth
	SET Price = CASE @UseUOM WHEN 2 THEN Price_LB ELSE Price_CS END

	UPDATE ##tmp_cur_growth
	SET Program_Rate = CASE 
						 WHEN @UseUOM = Unit_Of_Measure_ID THEN Rate
									 WHEN Unit_Of_Measure_ID = 3 THEN cast(Rate as Decimal(20,5)) * 0.01 * Price
									 WHEN @UseUOM = 1 AND Unit_Of_Measure_ID = 2 THEN Rate * Net_Weight
									 WHEN @UseUOM = 2 AND Unit_Of_Measure_ID = 1 THEN Rate / Net_Weight
									 END


	<!----------------------------- Gather details from existing program ------------------------------------------>

	-- Fixed Price
	IF OBJECT_ID('tempdb..##tmp_existing_fp') IS NOT NULL
	DROP TABLE ##tmp_existing_fp
	SELECT	cp.BSA_Foodservice_Items_Master_ID, cp.Item, cp.Description, 
			cm.Contract_Main_ID, cm.Contract_Number,CM.Contract_Title,
			CASE 
			WHEN @UseUOM = pd2.Unit_Of_Measure_ID THEN pd2.Fixed_Price_Value
			WHEN @UseUOM = 1 AND pd2.Unit_Of_Measure_ID = 2 THEN pd2.Fixed_Price_Value * cp.Net_Weight
			WHEN @UseUOM = 2 AND pd2.Unit_Of_Measure_ID = 1 THEN pd2.Fixed_Price_Value / cp.Net_Weight
			END as Other_Program_FP,
			CAST(0 as decimal(20, 4)) as Other_Program_FP_Rate,
			CASE @UseUOM WHEN 2 THEN price.Price_LB ELSE price.Price_CS END as Price,
			cn2.Program_Fixed_Component_Name
			,cm.contract_start_date
			,cm.contract_end_date
	INTO	##tmp_existing_fp
	FROM	##tmp_items cp
	INNER JOIN ##tmp_items price ON price.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
	<cfif arguments.is_component_checked or arguments.is_rate_checked>
	INNER JOIN ##tmp_cur_fp fp ON fp.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
	</cfif>
	INNER JOIN ##tmp_other_pgm cm on 1=1
	INNER JOIN Contract_Products cp2 ON cp2.Contract_Main_ID = cm.Contract_Main_ID AND cp2.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID AND cp2.Deleted = 0 AND cp2.Product_Type_ID = 1
	INNER JOIN Program_Fixed_Component c2 on c2.Program_ID = cp2.Contract_Main_ID AND c2.Deleted = 0 
	<cfif arguments.is_component_checked>
	AND c2.Program_Fixed_Component_Name_ID = fp.Program_Fixed_Component_Name_ID
	AND cp.Product_Type_ID = 1
	</cfif>
	INNER JOIN Program_Fixed_Component_Name cn2 on cn2.Program_Fixed_Component_Name_ID = c2.Program_Fixed_Component_Name_ID
	INNER JOIN Program_Fixed_Price_Product_Data pd2 
	ON 		pd2.Contract_Products_ID = cp2.Contract_Products_ID 
	AND 	pd2.Program_Fixed_Component_ID = c2.Program_Fixed_Component_ID
	AND 	pd2.Deleted = 0 		
	AND 	CAST(pd2.Fixed_Price_Value AS FLOAT) <> 0
	<cfif arguments.is_rate_checked>
		WHERE pd2.Fixed_Price_Value = fp.Fixed_Price_Value
		AND pd2.Unit_Of_Measure_ID = fp.Unit_Of_Measure_ID
	</cfif>	
	
	UPDATE	##tmp_existing_fp
	SET		Other_Program_FP_Rate = Price - Other_Program_FP 
	WHERE	Price > Other_Program_FP

	-- Rebate
	IF OBJECT_ID('tempdb..##tmp_existing_reb') IS NOT NULL
	DROP TABLE ##tmp_existing_reb
	SELECT	cp.BSA_Foodservice_Items_Master_ID, cp.Item, cp.Description, 
			cm.Contract_Main_ID, cm.Contract_Number,cm.Contract_Title,
			CASE 
			WHEN @UseUOM = cd2.Unit_Of_Measure_ID THEN cd2.Rate
			WHEN cd2.Unit_Of_Measure_ID = 3 THEN CAST(cd2.Rate AS Decimal(20,5)) * 0.01 * CASE @UseUOM WHEN 2 THEN price.Price_LB ELSE price.Price_CS END
			WHEN @UseUOM = 1 AND cd2.Unit_Of_Measure_ID = 2 THEN cd2.Rate * cp.Net_Weight
			WHEN @UseUOM = 2 AND cd2.Unit_Of_Measure_ID = 1 THEN cd2.Rate / cp.Net_Weight
			END as Other_Program_Rate,
			CASE @UseUOM WHEN 2 THEN price.Price_LB ELSE price.Price_CS END as Price
			,cn2.Program_Rebates_Component_Name
			,cm.contract_start_date
			,cm.contract_end_date
	INTO	##tmp_existing_reb
	FROM	##tmp_items cp
	INNER JOIN ##tmp_items price ON price.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
	<cfif arguments.is_component_checked or arguments.is_rate_checked>
	INNER JOIN ##tmp_cur_reb reb ON reb.BSA_Foodservice_Items_Master_ID = reb.BSA_Foodservice_Items_Master_ID
	</cfif>
	INNER JOIN ##tmp_other_pgm cm on 1=1
	INNER JOIN Contract_Products cp2 ON cp2.Contract_Main_ID = cm.Contract_Main_ID AND cp2.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID AND cp2.Deleted = 0 AND cp2.Product_Type_ID = 2
	INNER JOIN Program_Rebates_Component c2 on c2.Program_ID = cp2.Contract_Main_ID AND c2.Deleted = 0 
	<cfif arguments.is_component_checked>
	AND c2.Program_Rebates_Component_Name_ID = reb.Program_Rebates_Component_Name_ID
	AND cp.Product_Type_ID = 2
	</cfif>
	INNER JOIN Program_Rebates_Component_Name cn2 on cn2.Program_Rebates_Component_Name_ID = c2.Program_Rebates_Component_Name_ID
	INNER JOIN Program_Rebates_Product_Data pd2 on pd2.Contract_Products_ID = cp2.Contract_Products_ID AND pd2.Deleted = 0
	INNER JOIN Program_Rebates_Component_Data cd2 
	ON 		cd2.Program_Rebates_Product_Data_ID = pd2.Program_Rebates_Product_Data_ID 
	AND 	cd2.Program_Rebates_Component_ID = c2.Program_Rebates_Component_ID 
	AND 	cd2.Deleted = 0
	AND 	CAST(cd2.Rate AS FLOAT) <> 0
	<cfif arguments.is_rate_checked>
		WHERE cd2.Rate = reb.Rate
		AND cd2.Unit_Of_Measure_ID = reb.Unit_Of_Measure_ID
	</cfif>

	-- Growth
	IF OBJECT_ID('tempdb..##tmp_existing_growth') IS NOT NULL
	DROP TABLE ##tmp_existing_growth
	SELECT	cp.BSA_Foodservice_Items_Master_ID, cp.Item, cp.Description, 
			cm.Contract_Main_ID, cm.Contract_Number,cm.Contract_Title,
			CASE 
			WHEN @UseUOM = cd2.Unit_Of_Measure_ID THEN cd2.Rate
			WHEN cd2.Unit_Of_Measure_ID = 3 THEN CAST(cd2.Rate AS Decimal(20,5)) * 0.01 * CASE @UseUOM WHEN 2 THEN price.Price_LB ELSE price.Price_CS END
			WHEN @UseUOM = 1 AND cd2.Unit_Of_Measure_ID = 2 THEN cd2.Rate * cp.Net_Weight
			WHEN @UseUOM = 2 AND cd2.Unit_Of_Measure_ID = 1 THEN cd2.Rate / cp.Net_Weight
			END as Other_Program_Rate,
			CASE @UseUOM WHEN 2 THEN price.Price_LB ELSE price.Price_CS END as Price
			,cn2.Program_Growth_Components_Name
			,cm.contract_start_date
			,cm.contract_end_date
			,ROW_NUMBER() Over (Partition By c2.Program_Growth_Component_ID, pd2.Program_Growth_Component_Product_Data_ID Order By t2.Tier_Number Desc) as Tier_Max
	INTO	##tmp_existing_growth
	FROM	##tmp_items cp
	INNER JOIN ##tmp_items price ON price.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
	<cfif arguments.is_component_checked or arguments.is_rate_checked>
	INNER JOIN ##tmp_cur_growth growth ON growth.BSA_Foodservice_Items_Master_ID = growth.BSA_Foodservice_Items_Master_ID
	</cfif>
	INNER JOIN ##tmp_other_pgm cm on 1=1
	INNER JOIN Contract_Products cp2 ON cp2.Contract_Main_ID = cm.Contract_Main_ID AND cp2.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID AND cp2.Deleted = 0 AND cp2.Product_Type_ID = 4
	INNER JOIN Program_Growth_Components c2 on c2.Program_ID = cp2.Contract_Main_ID AND c2.Deleted = 0 
	<cfif arguments.is_component_checked>
	AND c2.Program_Growth_Components_Name_Id = growth.Program_Growth_Components_Name_Id
	AND cp.Product_Type_ID = 4
	</cfif>
	INNER JOIN Program_Growth_Components_Name cn2 on cn2.Program_Growth_Components_Name_Id = c2.Program_Growth_Components_Name_Id
	INNER JOIN Program_Growth_Component_Tiers t2 on t2.Program_Growth_Component_ID = c2.Program_Growth_Component_ID AND t2.Deleted = 0
	INNER JOIN Program_Growth_Component_Product_Data pd2 on pd2.Contract_Products_ID = cp2.Contract_Products_ID AND pd2.Deleted = 0	
	INNER JOIN Program_Growth_Component_Product_Tier_Data cd2 
	ON		cd2.Program_Growth_Component_Product_Data_ID = pd2.Program_Growth_Component_Product_Data_ID 
	AND		cd2.Program_Growth_Component_Tier_ID = t2.Program_Growth_Component_Tier_ID
	AND 	cd2.Deleted = 0
	AND 	CAST(cd2.Rate AS FLOAT) <> 0
	<cfif arguments.is_rate_checked>
		WHERE cd2.Rate = growth.Rate
		AND cd2.Unit_Of_Measure_ID = growth.Unit_Of_Measure_ID
	</cfif>
		
	-- We will consider max growth rate 	
	DELETE ##tmp_existing_growth WHERE Tier_Max > 1

	<CFIF arguments.reportType eq "Level1">
		IF OBJECT_ID('tempdb..##tmp_product_combined') IS NOT NULL
		DROP TABLE ##tmp_product_combined
		SELECT	tmp.BSA_Foodservice_Items_Master_ID, tmp.Item, tmp.Description, 
				CAST(null as decimal(20, 2)) as Min_Fixed_Price,
				CAST(null as decimal(20, 2)) as Sum_Rebate,
				CAST(null as decimal(20, 2)) as Sum_Growth,
				Count(*) as Overlap_Count
		INTO	##tmp_product_combined
		FROM	(
			SELECT	BSA_Foodservice_Items_Master_ID, Item, Description, Contract_Number
			FROM	##tmp_existing_fp 
			UNION
			SELECT	BSA_Foodservice_Items_Master_ID, Item, Description, Contract_Number
			FROM	##tmp_existing_reb
			UNION
			SELECT	BSA_Foodservice_Items_Master_ID, Item, Description, Contract_Number
			FROM	##tmp_existing_growth
		) as tmp
		Group By tmp.BSA_Foodservice_Items_Master_ID, tmp.Item, tmp.Description


		UPDATE	t
		SET		Min_Fixed_Price = tmp.Min_Other_Program_FP
		FROM	##tmp_product_combined t
		INNER JOIN (
			SELECT	BSA_Foodservice_Items_Master_ID, Min(Other_Program_FP) as Min_Other_Program_FP
			FROM	##tmp_existing_fp 
			Group By BSA_Foodservice_Items_Master_ID
		) tmp
		ON	tmp.BSA_Foodservice_Items_Master_ID = t.BSA_Foodservice_Items_Master_ID

		UPDATE	t
		SET		Sum_Rebate = tmp.Sum_Rebate
		FROM	##tmp_product_combined t
		INNER JOIN (
			SELECT	BSA_Foodservice_Items_Master_ID, Sum(Other_Program_Rate) as Sum_Rebate
			FROM	##tmp_existing_reb 
			Group By BSA_Foodservice_Items_Master_ID
		) tmp
		ON	tmp.BSA_Foodservice_Items_Master_ID = t.BSA_Foodservice_Items_Master_ID
		
		UPDATE	t
		SET		Sum_Growth = tmp.Sum_Growth
		FROM	##tmp_product_combined t
		INNER JOIN (
			SELECT	BSA_Foodservice_Items_Master_ID, Sum(Other_Program_Rate) as Sum_Growth
			FROM	##tmp_existing_growth 
			Group By BSA_Foodservice_Items_Master_ID
		) tmp
		ON	tmp.BSA_Foodservice_Items_Master_ID = t.BSA_Foodservice_Items_Master_ID

		SELECT	*
		FROM	##tmp_product_combined
	<CFELSE>
		
		IF OBJECT_ID('tempdb..##tmp_existing_program_rates') IS NOT NULL
		DROP TABLE ##tmp_existing_program_rates

		SELECT	BSA_Foodservice_Items_Master_ID, Item, Contract_Main_ID, Contract_Number, Price, Other_Program_FP as Fixed_Price, null as Rebate, null as Growth, Other_Program_FP_Rate as Spend, Program_Fixed_Component_Name as Component, Contract_Title,contract_start_date
			,contract_end_date
		INTO	##tmp_existing_program_rates
		FROM	##tmp_existing_fp
		UNION
		SELECT	BSA_Foodservice_Items_Master_ID, Item, Contract_Main_ID, Contract_Number, Price, null as Fixed_Price, Other_Program_Rate as Rebate, null as Growth, Other_Program_Rate as Spend, Program_Rebates_Component_Name as Component, Contract_Title,contract_start_date
			,contract_end_date
		FROM	##tmp_existing_reb
		UNION
		SELECT	BSA_Foodservice_Items_Master_ID, Item, Contract_Main_ID, Contract_Number, Price, null as Fixed_Price, null as Rebate, Other_Program_Rate as Growth, Other_Program_Rate as Spend, Program_Growth_Components_Name as Component, Contract_Title,contract_start_date
			,contract_end_date
		FROM	##tmp_existing_growth
		
		<!----------------------------- Output existing program details ------------------------------------------>
		SELECT	r.*, c.Shr_Ship_To, c.Name
		FROM	##tmp_existing_program_rates r
		INNER JOIN Contract_Distributors cd
		on		cd.Contract_Main_ID = r.Contract_Main_ID
		and		cd.Deleted = 0
		and		cd.Is_Group = 0
		INNER JOIN BSA_Foodservice_Customers c
		on		c.BSA_Foodservice_Customers_ID = cd.BSA_Foodservice_Customers_ID
		<cfif arguments.filter_distributor>
		WHERE	EXISTS (
			SELECT	1
			FROM	##tmp_distributors d
			WHERE	d.BSA_Foodservice_Customers_ID = cd.BSA_Foodservice_Customers_ID
		)
		</cfif>
	</CFIF>
		</cfquery>

<cfset duplicates.qDuplicatesByProducts=duplicate(qDuplicatesByProducts)>

<CFIF arguments.reportType neq "Level1">
	<CFQUERY name="qGetCurrentProgram" datasource="#application.datasource#">
		<!----------------------------- Output current program details ------------------------------------------>
		SELECT	tmp.BSA_Foodservice_Items_Master_ID, tmp.Item, tmp.Description, tmp.Price, fp.Fixed_Price, 
				reb.Rebate, growth.Growth, 
				ISNULL(fp.Program_FP_Rate, 0) + ISNULL(reb.Rebate, 0) + ISNULL(growth.Growth, 0) as Spend, 
				tmp.contract_start_date, tmp.contract_end_date
		FROM	(
			SELECT	BSA_Foodservice_Items_Master_ID, Item, Description, Price, contract_start_date, contract_end_date 
			FROM	##tmp_cur_fp 
			UNION
			SELECT	BSA_Foodservice_Items_Master_ID, Item, Description, Price, contract_start_date, contract_end_date 
			FROM	##tmp_cur_reb
			UNION
			SELECT	BSA_Foodservice_Items_Master_ID, Item, Description, Price, contract_start_date, contract_end_date 
			FROM	##tmp_cur_growth
		) as tmp
		LEFT JOIN ##tmp_cur_fp fp on fp.BSA_Foodservice_Items_Master_ID = tmp.BSA_Foodservice_Items_Master_ID
		LEFT JOIN (
			SELECT	BSA_Foodservice_Items_Master_ID, SUM(Program_Rate) as Rebate
			FROM	##tmp_cur_reb reb 
			GROUP BY BSA_Foodservice_Items_Master_ID
		) as reb ON reb.BSA_Foodservice_Items_Master_ID = tmp.BSA_Foodservice_Items_Master_ID
		LEFT JOIN (
			SELECT	BSA_Foodservice_Items_Master_ID, SUM(Program_Rate) as Growth
			FROM	##tmp_cur_growth growth
			GROUP BY BSA_Foodservice_Items_Master_ID
		) as growth ON growth.BSA_Foodservice_Items_Master_ID = tmp.BSA_Foodservice_Items_Master_ID
	</CFQUERY>
	
	<cfset duplicates.qGetCurrentProgram=duplicate(qGetCurrentProgram)>
</CFIF>

<cfreturn duplicates>

	</cffunction>
			
</cfcomponent>