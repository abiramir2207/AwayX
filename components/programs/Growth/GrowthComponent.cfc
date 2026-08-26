<cfcomponent hint="This class should be the core functionality to handle application settings growth components" extends="components.programs.Program">
	<cffunction name="init" output="false">
		<cfreturn this />
	</cffunction>
	<cffunction name="canDelete" output="false" returntype="boolean" hint="Function used to verify if a component can be deleted or not.">	
   		<cfargument name="nameID" type="numeric" required="false" default="" />
		<cfquery name="qCheckCompName" datasource="#application.datasource#">
			SELECT 	count(*) as count
			FROM 	Program_Growth_Components
			WHERE 	Growth_Component_Name_Id = <cfqueryparam value="#arguments.nameID#" cfsqltype="CF_SQL_INTEGER" />
			AND 	deleted = 0 
		</cfquery>
		<!---if we get a count back from qCheckCompName then set canDelete to false--->
		<cfif qCheckCompName.count>
			<cfset bCanDelete = false />
		<cfelse>
			<cfset bCanDelete = true />
		</cfif>
		<cfreturn bCanDelete />
   </cffunction>
   
   <!------ add ----->
   	<cffunction name="add" output="false" hint="Function used to add a new component.">
		<cfargument name="componentName" required="false" default="" />
		<cfargument name="externalID" required="false" default="" />
		<cfargument name="operatingGroupId" required="false" default="0" />
		<cfargument name="allowanceCodeId" required="false" default="0" />
		<cfargument name="selectedTemplateIdList" required="false" default="" />
		<cfargument name="Accrual_On" required="false" default="0" />
		<cfargument name="Exclude_Brokerage" required="false" default="0" />
		<cfargument name="User_ID" required="false" default="" />
		<cfargument name="GLList" required="false" default="" />
		<cfargument name="Deduction_Account" required="false" default="" />
		<cfargument name="Payment_Account" required="false" default="" />
		<cfargument name="FOB_PayeeType1_DiscountType" type="string" required="false" default="" />
		<cfargument name="FOB_PayeeType2_DiscountType" type="string" required="false" default="" />
		<cfargument name="FOB_PayeeType3_DiscountType" type="string" required="false" default="" />
<!--- Dev Note: drachala; D28881: Update growth component settings to include additional elements  START
Added/Changed: Added below 5 Argumnets--->
		<cfargument name="Growth_Percent_Option_ID" type="numeric" required="false" default="1" />
		<cfargument name="Auto_Pay_Net_Of_Cash_Discount" type="boolean" required="false" default="0" />
		<cfargument name="Auto_Pay_Net_Of_Freight_Allowance" type="boolean" required="false" default="0" />
		<cfargument name="Auto_Pay_Exclude_Credit_Type" type="boolean" required="false" default="0" />
		<cfargument name="Credit_Type_Select" type="string" required="false" default="" />
	<!--- End Dev Note: drachala; D28881: Update growth component settings to include additional elements  --->
		<cfargument name="TemplatePaidToDefaultCFPages" required="false" default="" type="string"  />
		<cfargument name="TemplatePaidToDefaultRatesGrid" required="false" default="" type="string"  />
		<cfargument name="structTemplatePaidTo" required="false" default="structNew()" type="struct"  />

		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<cfargument name="DisplayID" required="false" default="0" />
		<cfargument name="DisplayDeductionAccount" required="false" default="0" />
		<cfargument name="DisplayPaymentAccount" required="false" default="0" />		
		<!--- D58135 ::  Additional Component info displaye inside program END --->
		<cfargument name="ProgramLockTypeID" required="false" default="0" />

		<cfargument name="TPO_Field" required="false" default="0" /> <!--- 95126 --->
		<cfargument name="TPO_Rate_Type" required="false" default="0" /> <!---95126 --->


		<cfset bCompNameExists = 0 />
		<cfset bProceedWithInsert = 1 />
		
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT	Program_Growth_Components_Name_Id, External_ID
			FROM	Program_Growth_Components_Name
			WHERE	Program_Growth_Components_Name = '#trim(arguments.componentName)#'
			AND		deleted = 0
		</cfquery>
		<cfif qGetActiveComps.RecordCount>
			<cfset bProceedWithInsert = 0 />
			<!------ if names are same do not have to insert ----->
			<cfset bCompNameExists = 1 />
			<!------ if there is any existing component which has same name but different id, notify  ----->
			<cfif application.returned_customer_setting.external_id_on EQ 1>
				<cfloop query="qGetActiveComps">
					<cfif External_ID NEQ arguments.externalID>
						<cfset bCompNameExists = 2 />
						<cfbreak />
					</cfif>					
				</cfloop>
			</cfif>		
		</cfif>
		
		<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
		<!------ Check if another componet (any discountype) have teh same allowance code ----->
		<cfif bProceedWithInsert EQ 1>
			<!------ going to re-use the code to get list of all component names for diffent discount types ----->			
			<cfset discountTypeList = templateManager.getComponentDiscountTypeList() />
			<cfset qGetAllTemplateDiscountComponents = templateManager.getAllTemplateDiscountComponents(0, discountTypeList, 0) />	
			<cfset usedAllowanceCodes = ValueList(qGetAllTemplateDiscountComponents.Allowance_Code_ID) />
			<cfif ListFindNOCase(usedAllowanceCodes, arguments.allowanceCodeId) NEQ 0>
				<cfset bProceedWithInsert = 0 />
				<cfset bCompNameExists = 3 />
			</cfif>
		</cfif>		
		
		<cfif bProceedWithInsert>
				<!---Dev Note: drachala; D28881: Update growth component settings to include additional elements  --->
			<cfif arguments.Growth_Percent_Option_ID neq 1> <!--- 1=net sales, 2=gross sales dr--->
				<cfset arguments.Auto_Pay_Net_Of_Cash_Discount = 0 />
				<cfset arguments.Auto_Pay_Net_Of_Freight_Allowance = 0 />
				<cfset arguments.Auto_Pay_Exclude_Credit_Type = 0 />
			</cfif>
			<cfif arguments.Auto_Pay_Exclude_Credit_Type eq 0>
				<cfset arguments.Credit_Type_Select = "" />
			</cfif>
				<!--- End Dev Note: drachala; D28881: Update growth component settings to include additional elements  --->

			<cfquery name="qGetActiveComps" datasource="#application.datasource#">
				SET NOCOUNT ON
				INSERT INTO	Program_Growth_Components_Name
					(Program_Growth_Components_Name, 
					External_ID, 
					Operating_Group_ID, 
					Allowance_Code_ID, 
					Accrual_On, 
					Exclude_Brokerage, 
					Deduction_Account, 
					Payment_Account, 
					Last_Edited_By, 
					Last_Edited_Date,
					Growth_Percent_Option_ID,
					Auto_Pay_Net_Of_Cash_Discount,
					Auto_Pay_Net_Of_Freight_Allowance,
					Auto_Pay_Exclude_Credit_Type
					<!--- D58135 ::  Additional Component info displaye inside program START--->					
					,ID_on_ViewProgramPage
					,DeductionAccount_on_ViewProgramPage
					,PaymentAccount_on_ViewProgramPage	
					<!--- D58135 ::  Additional Component info displaye inside program END--->
					,Program_Lock_Type_ID
					,TPO_Field <!---95126 --->
					,TPO_Rate_Type <!---95126 --->							
					)
				VALUES
					('#arguments.componentName#', 
					'#arguments.externalID#',
					<cfqueryparam value="#arguments.operatingGroupId#" cfsqltype="CF_SQL_INTEGER" null="#arguments.operatingGroupId EQ 0#">,
					<cfqueryparam value="#arguments.allowanceCodeId#" cfsqltype="CF_SQL_INTEGER" null="#arguments.allowanceCodeId EQ 0#">,
					<cfqueryparam value="#arguments.Accrual_On#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.Exclude_Brokerage#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.Deduction_Account#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.Payment_Account#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
					getdate(),
					<cfqueryparam value="#arguments.Growth_Percent_Option_ID#" cfsqltype="CF_SQL_INTEGER" >,
					<cfqueryparam value="#arguments.Auto_Pay_Net_Of_Cash_Discount#" cfsqltype="cf_sql_bit" >,
					<cfqueryparam value="#arguments.Auto_Pay_Net_Of_Freight_Allowance#" cfsqltype="cf_sql_bit" >,
					<cfqueryparam value="#arguments.Auto_Pay_Exclude_Credit_Type#" cfsqltype="cf_sql_bit" >
					<!--- D58135 ::  Additional Component info displaye inside program START--->
					,<cfqueryparam value="#arguments.DisplayID#" cfsqltype="cf_sql_bit">
					,<cfqueryparam value="#arguments.DisplayDeductionAccount#" cfsqltype="cf_sql_bit">
					,<cfqueryparam value="#arguments.DisplayPaymentAccount#" cfsqltype="cf_sql_bit">
					<!--- D58135 ::  Additional Component info displaye inside program END--->
					,<cfqueryparam value="#arguments.ProgramLockTypeID#" cfsqltype="CF_SQL_INTEGER">
					,<cfqueryparam value="#arguments.TPO_Field#" cfsqltype="CF_SQL_INTEGER"> <!--- 95126 --->
					,<cfqueryparam value="#arguments.TPO_Rate_Type#" cfsqltype="CF_SQL_INTEGER"> <!--- 95126 --->						
					)
				SELECT Program_Growth_Components_Name_ID = @@IDENTITY
				SET NOCOUNT OFF
			</cfquery>
			
			<Cfif len(trim(arguments.GLList)) GT 0>
				<cfloop list="#arguments.GLList#" index="GL_Account_ID">
				<cfquery name="InsertGLs" datasource="#application.datasource#">
				INSERT INTO GL_Component_Mapping
				(
					GL_Account_ID,
					Component_Name_ID,
					Discount_Type_ID
				)
				VALUES
				(
					'#GL_Account_ID#',
					'#qGetActiveComps.Program_Growth_Components_Name_ID#',
					4
				)
				</cfquery>
				</cfloop>
			</Cfif>
<!--- Dev Note: drachala; D28881: Update growth component settings to include additional elements  START
Added/Changed: Added this function to SaveCredit TypeExclusion--->
			<cfset saveCreditTypeExclusion(
					Growth_Component_Name_ID = qGetActiveComps.Program_Growth_Components_Name_ID,
					Credit_Type_Select = arguments.Credit_Type_Select
					) />
<!--- End Dev Note: drachala; D28881: Update growth component settings to include additional elements  --->			
			<cfset templateManager.saveDiscountComponentTemplates(qGetActiveComps.Program_Growth_Components_Name_ID, 4, arguments.selectedTemplateIdList,
				arguments.TemplatePaidToDefaultCFPages, arguments.TemplatePaidToDefaultRatesGrid, arguments.structTemplatePaidTo) />
			
			<cfset application.oController.getObject(path="mvc.Models.Settings.FOBPriceIndicatorManager",name="FOBPriceIndicatorManager",bReload= 0) />
			<!--- save auto pay fob price indicator list for payee = distributor --->
			<cfset application.oFOBPriceIndicatorManager.saveProgramComponentFOBPriceIndicator(
					payeeTypeId = 1,
					discountTypeId = 4,
					componentNameId = qGetActiveComps.Program_Growth_Components_Name_ID,
					FOBList = arguments.FOB_PayeeType1_DiscountType) />
			<!--- save auto pay fob price indicator list for payee = operator --->
			<cfset application.oFOBPriceIndicatorManager.saveProgramComponentFOBPriceIndicator(
					payeeTypeId = 2,
					discountTypeId = 4,
					componentNameId = qGetActiveComps.Program_Growth_Components_Name_ID,
					FOBList = arguments.FOB_PayeeType2_DiscountType) />
			<!--- save auto pay fob price indicator list for payee = broker --->
			<cfset application.oFOBPriceIndicatorManager.saveProgramComponentFOBPriceIndicator(
					payeeTypeId = 3,
					discountTypeId = 4,
					componentNameId = qGetActiveComps.Program_Growth_Components_Name_ID,
					FOBList = arguments.FOB_PayeeType3_DiscountType) />
					
		</cfif>
		
		<cfreturn bCompNameExists />
   	</cffunction>
	
	<!--- active/inactive methods--->
	<cffunction name="getActive" output="false" returntype="query">
		<cfargument name="arAllowList" type="array" required="false" default="#ArrayNew(1)#" />
		<cfargument name="arExcludeList" type="any" required="false" default="0" />

		<cfset arAllowListLen = ArrayLen(arguments.arAllowList) />
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT 	DISTINCT Program_Growth_Components_Name.*,
					Allowance_Code.Allowance_Code_Number, Allowance_Code.Allowance_Code_Desc,				
				(SELECT TOP 1 GL_Component_Mapping.GL_Account_ID
				FROM GL_Component_Mapping
				WHERE GL_Component_Mapping.Component_Name_ID = Program_Growth_Components_Name.Program_Growth_Components_Name_ID
				AND GL_Component_Mapping.Discount_Type_ID = 4
				AND GL_Account_ID IS NOT NULL
				) As GL_Account_ID
			FROM 	Program_Growth_Components_Name
			
			LEFT JOIN Allowance_Code
			ON		Allowance_Code.Allowance_Code_ID = Program_Growth_Components_Name.Allowance_Code_ID
					
			/* Get the GL_Code_Account_ID for the component to check whether validation for 
			 required GL_Code_Account_ID is required or not 
			*/
			LEFT JOIN GL_Component_Mapping
			ON GL_Component_Mapping.Component_Name_ID = Program_Growth_Components_Name.Program_Growth_Components_Name_ID
			AND GL_Component_Mapping.Discount_Type_ID = 4
			
			WHERE 	Program_Growth_Components_Name.Deleted = 0
			<cfif appSettings.get_Setting('Forbid_Same_Component_Same_Pays_To_In_Program') EQ '1'>
				AND Program_Growth_Components_Name_Id NOT IN(#arExcludeList#)
			</cfif>			
			AND		Program_Growth_Components_Name.Active = 1
			<cfloop from="1" to="#arAllowListLen#" index="i">
			<cfset lAllowList = arAllowList[i] />
			<cfif Len(lAllowList) EQ 0>
				AND 1=2
			<cfelse>
				AND	Program_Growth_Components_Name_Id  IN (#lAllowList#)
			</cfif>
			</cfloop>
			ORDER BY Program_Growth_Components_Name
		</cfquery>
		<cfreturn qGetActiveComps />
   	</cffunction>
	<cffunction name="getInActive" output="false" returntype="query">	
		<cfset useLakebaseForqGetInActiveComps = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components_name")>
<cfif useLakebaseForqGetInActiveComps>
	<cftry>
		<cfset qGetInActiveComps = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_growth_components_name", {
				"deleted" = "eq.0",
				"active" = "eq.0",
				"order" = "program_growth_components_name.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetInActiveComps = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetInActiveComps>
<cfquery name="qGetInActiveComps" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Program_Growth_Components_Name
			WHERE 	Deleted = 0
			AND		Active = 0
			ORDER BY Program_Growth_Components_Name
		</cfquery>
</cfif>
		<cfreturn qGetInActiveComps />
   	</cffunction>
	<!--- activate/deactivate --->
	<cffunction name="activate" output="false" hint="Function used to activate components.">
		<cfargument name="compIds" required="false" default="" />	
		<cfquery datasource="#application.datasource#">
			UPDATE 	Program_Growth_Components_Name
			SET		Active = 1
			WHERE	Program_Growth_Components_Name_Id IN(#arguments.compIds#)
		</cfquery>
   	</cffunction>
	<cffunction name="deactivate" output="false" hint="Function used to deactivate components.">
		<cfargument name="compIds" required="false" default="" />	
		<cfquery datasource="#application.datasource#">
			UPDATE 	Program_Growth_Components_Name
			SET		Active = 0
			WHERE	Program_Growth_Components_Name_Id IN(#arguments.compIds#)
		</cfquery>
   	</cffunction>
	<!--- delete/undelete --->
	<cffunction name="delete" output="false" hint="Function used to delete components.">
		<cfargument name="compIds" required="false" default="" />	
		<cfquery datasource="#application.datasource#">
			UPDATE 	Program_Growth_Components_Name
			SET		Deleted = 1
			WHERE	Program_Growth_Components_Name_Id IN(#arguments.compIds#)
		</cfquery>
   	</cffunction>
	<!--- getComponent--->
	<cffunction name="getComp" output="false" returntype="query">	
   		<cfargument name="compId" required="false" default=0 />
		<cfset useLakebaseForqGetComp = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components_name")>
<cfif useLakebaseForqGetComp>
	<cftry>
		<cfset qGetComp = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_growth_components_name", {
				"program_growth_components_name_id" = "eq.#arguments.compId#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetComp = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetComp>
<cfquery name="qGetComp" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Program_Growth_Components_Name
			WHERE 	Program_Growth_Components_Name_Id = #arguments.compId#	
		</cfquery>
</cfif>
		<cfreturn qGetComp />
   	</cffunction>
	
	<!---update --->
	<cffunction name="update" output="false" hint="Function used to update components." returntype="numeric">
		<cfargument name="compId" required="false" default="" />
		<cfargument name="compName" required="false" default="" />
		<cfargument name="externalID" required="false" default="" />
		<cfargument name="operatingGroupId" required="false" default="0" />
		<cfargument name="allowanceCodeId" required="false" default="0" />
		<cfargument name="selectedTemplateIdList" required="false" default="" />
		<cfargument name="Accrual_On" required="false" default="0" />
		<cfargument name="Exclude_Brokerage" required="false" default="0" />
		<cfargument name="User_ID" required="false" default="">
		<cfargument name="GLList" required="false" default="" />
		<cfargument name="Deduction_Account" required="false" default="" />
		<cfargument name="Payment_Account" required="false" default="" />
		<cfargument name="FOB_PayeeType1_DiscountType" type="string" required="false" default="" />
		<cfargument name="FOB_PayeeType2_DiscountType" type="string" required="false" default="" />
		<cfargument name="FOB_PayeeType3_DiscountType" type="string" required="false" default="" />
		<cfargument name="Growth_Percent_Option_ID" type="numeric" required="false" default="1" />
		<cfargument name="Auto_Pay_Net_Of_Cash_Discount" type="boolean" required="false" default="0" />
		<cfargument name="Auto_Pay_Net_Of_Freight_Allowance" type="boolean" required="false" default="0" />
		<cfargument name="Auto_Pay_Exclude_Credit_Type" type="boolean" required="false" default="0" />
		<cfargument name="Credit_Type_Select" type="string" required="false" default="" />
		<cfargument name="TemplatePaidToDefaultCFPages" required="false" default="" type="string"  />
		<cfargument name="TemplatePaidToDefaultRatesGrid" required="false" default="" type="string"  />
		<cfargument name="structTemplatePaidTo" required="false" default="structNew()" type="struct"  />
		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<cfargument name="DisplayID" required="false" default="0" />
		<cfargument name="DisplayDeductionAccount" required="false" default="0" />
		<cfargument name="DisplayPaymentAccount" required="false" default="0" />		
		<!--- D58135 ::  Additional Component info displaye inside program END --->
		<cfargument name="ProgramLockTypeID" required="false" default="0" />

		<cfargument name="TPO_Field" required="false" default="0" /> <!--- 95126 --->
		<cfargument name="TPO_Rate_Type" required="false" default="0" /> <!---95126 --->	

		<cfset bCompNameExists = 0 />
		<cfset bProceedWithUpdate = 1 />
		
		<!---check to see if the name already exists--->		
		<cfquery name="qCheckCompNames" datasource="#application.datasource#">
			SELECT	*
			FROM	Program_Growth_Components_Name
			WHERE	Program_Growth_Components_Name = '#trim(arguments.compName)#'
			AND		Program_Growth_Components_Name_Id != #arguments.compId#		
			AND		deleted = 0
		</cfquery>
		<!---If the name exists then set does not exist to false--->
		<cfif qCheckCompNames.RecordCount>
			<cfset bCompNameExists = 1 />
			<cfset bProceedWithUpdate = 0 />
		</cfif>
		
		<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
		<!------ Check if another componet (any discountype) have teh same allowance code ----->
		<cfif bProceedWithUpdate EQ 1>
			<!------ going to re-use the code to get list of all component names for diffent discount types ----->			
			<cfset discountTypeList = templateManager.getComponentDiscountTypeList() />
			<cfset qGetAllTemplateDiscountComponents = templateManager.getAllTemplateDiscountComponents(0, discountTypeList, 0) />	
			<cfset usedAllowanceCodes = ValueList(qGetAllTemplateDiscountComponents.Allowance_Code_ID) />
			<cfif ListFindNOCase(usedAllowanceCodes, arguments.allowanceCodeId) NEQ 0>
				<!------ check if this allowance cod eis used by teh same component ----->
				<cfquery name="qCheckIfCurrentcomponent" dbtype="query">
					SELECT	Component_ID
					FROM	qGetAllTemplateDiscountComponents
					WHERE	Allowance_Code_ID = #arguments.allowanceCodeId#
					AND		Component_ID = #arguments.compId#
				</cfquery>
				<cfif not qCheckIfCurrentcomponent.recordCount>
					<cfset bProceedWithUpdate = 0 />
					<cfset bCompNameExists = 3 />
				</cfif>
			</cfif>

			<cfif arguments.Auto_Pay_Exclude_Credit_Type eq 0>
				<cfset arguments.Credit_Type_Select = "" />
			</cfif>
		</cfif>		
		
		<cfif bProceedWithUpdate>
			<cfquery datasource="#application.datasource#">
				UPDATE 	Program_Growth_Components_Name
				SET		Program_Growth_Components_Name = '#arguments.compName#',
						External_ID = '#arguments.externalID#',
						Operating_Group_ID = <cfqueryparam value="#arguments.operatingGroupId#" cfsqltype="CF_SQL_INTEGER" null="#arguments.operatingGroupId EQ 0#">,
						Allowance_Code_ID = <cfqueryparam value="#arguments.allowanceCodeId#" cfsqltype="CF_SQL_INTEGER" null="#arguments.allowanceCodeId EQ 0#">,
						Accrual_On = <cfqueryparam value="#arguments.Accrual_On#" cfsqltype="CF_SQL_INTEGER">,
						Exclude_Brokerage = <cfqueryparam value="#arguments.Exclude_Brokerage#" cfsqltype="CF_SQL_INTEGER">,
						Deduction_Account = <cfqueryparam value="#arguments.Deduction_Account#" cfsqltype="CF_SQL_VARCHAR">,
						Payment_Account = <cfqueryparam value="#arguments.Payment_Account#" cfsqltype="CF_SQL_VARCHAR">,
						Last_Edited_By = <cfqueryparam value="#arguments.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
						Last_Edited_Date = getdate(),
						Growth_Percent_Option_ID = <cfqueryparam value="#arguments.Growth_Percent_Option_ID#" cfsqltype="CF_SQL_INTEGER" >,
						Auto_Pay_Net_Of_Cash_Discount = <cfqueryparam value="#arguments.Auto_Pay_Net_Of_Cash_Discount#" cfsqltype="cf_sql_bit" >,
						Auto_Pay_Net_Of_Freight_Allowance = <cfqueryparam value="#arguments.Auto_Pay_Net_Of_Freight_Allowance#" cfsqltype="cf_sql_bit" >,
						Auto_Pay_Exclude_Credit_Type = <cfqueryparam value="#arguments.Auto_Pay_Exclude_Credit_Type#" cfsqltype="cf_sql_bit" >
						<!--- D58135 ::  Additional Component info displaye inside program START--->
						,ID_on_ViewProgramPage = <cfqueryparam value="#arguments.DisplayID#" cfsqltype="cf_sql_bit">
						,DeductionAccount_on_ViewProgramPage = <cfqueryparam value="#arguments.DisplayDeductionAccount#" cfsqltype="cf_sql_bit">
						,PaymentAccount_on_ViewProgramPage	= <cfqueryparam value="#arguments.DisplayPaymentAccount#" cfsqltype="cf_sql_bit">
						<!--- D58135 ::  Additional Component info displaye inside program END--->
						,Program_Lock_Type_ID = <cfqueryparam value="#arguments.ProgramLockTypeID#" cfsqltype="CF_SQL_INTEGER">
						,TPO_Field = <cfqueryparam value="#arguments.TPO_Field#" cfsqltype="CF_SQL_INTEGER"> <!--- 95126--->
						,TPO_Rate_Type = <cfqueryparam value="#arguments.TPO_Rate_Type#" cfsqltype="CF_SQL_INTEGER"> <!--- 95126--->						
				WHERE	Program_Growth_Components_Name_Id = #arguments.compId#
			</cfquery>
			
			<cfif len(trim(arguments.GLList)) GT 0>
				<cfloop list="#arguments.GLList#" index="GL_Account_ID">
					<cfquery name="DeletefromMapping" datasource="#application.datasource#">
					DELETE FROM GL_Component_Mapping 
					WHERE GL_Account_ID = '#GL_Account_ID#'
					AND Component_Name_ID = '#arguments.compId#'
					AND Discount_Type_ID = 4
					</cfquery>
				</cfloop>
			</cfif>

			<!---  Update growth component settings to include additional elements. Added this function call to Save Credit Type Exclusion --->
			<cfset saveCreditTypeExclusion(
					Growth_Component_Name_ID = arguments.compId,
					Credit_Type_Select = arguments.Credit_Type_Select
					) />
			
			<cfset templateManager.saveDiscountComponentTemplates(arguments.compId, 4, arguments.selectedTemplateIdList,
				arguments.TemplatePaidToDefaultCFPages, arguments.TemplatePaidToDefaultRatesGrid, arguments.structTemplatePaidTo) />
			
			<cfset application.oController.getObject(path="mvc.Models.Settings.FOBPriceIndicatorManager",name="FOBPriceIndicatorManager",bReload= 0) />
			<!--- save auto pay fob price indicator list for payee = distributor --->
			<cfset application.oFOBPriceIndicatorManager.saveProgramComponentFOBPriceIndicator(
					payeeTypeId = 1,
					discountTypeId = 4,
					componentNameId = arguments.compId,
					FOBList = arguments.FOB_PayeeType1_DiscountType) />
			<!--- save auto pay fob price indicator list for payee = operator --->
			<cfset application.oFOBPriceIndicatorManager.saveProgramComponentFOBPriceIndicator(
					payeeTypeId = 2,
					discountTypeId = 4,
					componentNameId = arguments.compId,
					FOBList = arguments.FOB_PayeeType2_DiscountType) />
			<!--- save auto pay fob price indicator list for payee = broker --->
			<cfset application.oFOBPriceIndicatorManager.saveProgramComponentFOBPriceIndicator(
					payeeTypeId = 3,
					discountTypeId = 4,
					componentNameId = arguments.compId,
					FOBList = arguments.FOB_PayeeType3_DiscountType) />
					
		</cfif>
		
		<cfreturn bCompNameExists />
   	</cffunction>

	<cffunction name="getGrowthComparisonPeriodUOM" output="false" returntype="query" hint="Function used to Get Growth Comparison Period UOM's.">	
		<cfquery name="qgetGrowthComparisonPeriodUOM" datasource="#application.datasource#">
			SELECT 	*
			FROM Program_Growth_Comparison_Period_UOM
			WHERE Deleted = 0
		</cfquery>
		<cfreturn qgetGrowthComparisonPeriodUOM />
   	</cffunction>	

	<cffunction name="GetGrowthTierPercentUOM" output="false" returntype="query">
	
		<cfargument name="Program_Growth_Component_ID" required="true" type="string">

		<CFQUERY dataSource="#application.datasource#" NAME="qGetGrowthTierPercentUOM">
			SELECT Program_Growth_Comparison_Period_UOM_ID
			FROM 	Program_Growth_Components
			WHERE Program_Growth_Component_ID = '#arguments.Program_Growth_Component_ID#'
			AND Deleted = 0
		</CFQUERY>
			
		<cfreturn qGetGrowthTierPercentUOM />

	</cffunction>
<!--- Dev Note: drachala; D28881: Update growth component settings to include additional elements  START
Added/Changed: Added SaveCreditTypeExclusion Functions --->
	<cffunction name="saveCreditTypeExclusion" returntype="void" output="false">
		<cfargument name="Growth_Component_Name_ID" type="numeric" required="true" />
		<cfargument name="Credit_Type_Select" type="string" required="true" />
		
		<cfquery name="qDeleteExistingCreditTypeExclusions" datasource="#application.datasource#">
			DELETE 	Program_Growth_Credit_Type_Exclusion 
			WHERE	Program_Growth_Component_Name_ID = <cfqueryparam value="#Growth_Component_Name_ID#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfif arguments.Credit_Type_Select neq "">
			<cfloop list="#arguments.Credit_Type_Select#" index="creditTypeId">
				<cfquery name="qInsertCreditTypeExclusion" datasource="#application.datasource#">
					INSERT INTO Program_Growth_Credit_Type_Exclusion (Program_Growth_Component_Name_ID, Credit_Type_ID)
					VALUES (
					<cfqueryparam value="#Growth_Component_Name_ID#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#creditTypeId#" cfsqltype="cf_sql_integer">
					)
				</cfquery>
			</cfloop>
			<cfquery name="qInsertCreditTypeExclusionHistory" datasource="#application.datasource#">
				INSERT INTO Program_Growth_Credit_Type_Exclusion_History (Program_Growth_Credit_Type_Exclusion_ID, Program_Growth_Component_Name_ID, Credit_Type_ID)
				SELECT	Program_Growth_Credit_Type_Exclusion_ID, Program_Growth_Component_Name_ID, Credit_Type_ID
				FROM	Program_Growth_Credit_Type_Exclusion
				WHERE	Program_Growth_Component_Name_ID = <cfqueryparam value="#Growth_Component_Name_ID#" cfsqltype="cf_sql_integer">
			</cfquery>
		</cfif>
		
	</cffunction>	
<!--- End Dev Note: drachala; D28881: Update growth component settings to include additional elements  --->
<!--- Dev Note: drachala; D28881: Update growth component settings to include additional elements  START
Added/Changed: Added GetCreditTypeExclusion Functions--->
	<cffunction name="getCreditTypeExclusion" returntype="query" output="false">
		<cfargument name="Growth_Component_Name_ID" type="numeric" required="true" />
		
		<cfquery name="qGetCreditTypeExclusionHistory" datasource="#application.datasource#">
			SELECT	Program_Growth_Component_Name_ID, Credit_Type_ID
			FROM	Program_Growth_Credit_Type_Exclusion
			WHERE	Program_Growth_Component_Name_ID = <cfqueryparam value="#Growth_Component_Name_ID#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfreturn qGetCreditTypeExclusionHistory />
		
	</cffunction>
<!--- End Dev Note: drachala; D28881: Update growth component settings to include additional elements  --->
</cfcomponent>