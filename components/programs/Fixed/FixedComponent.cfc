<cfcomponent>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

   <cffunction name="set" output="false" returntype="struct">

	  	<cfargument name="compID" type="string" required="true" default="">
		<cfargument name="compNameId" type="string" required="true" default="">
		<cfargument name="programID" type="numeric" required="true" default=0>
		<cfargument name="compName" type="string" required="true" default="">
		<cfargument name="compUUID" type="string" required="true" default="#CreateUUID()#">
		<cfargument name="GL_Account_ID" type="string" required="false" default="">
		<cfargument name="Claim_Mechanics" type="string" required="false" default="">
		<cfargument name="Deduction_Account" type="string" required="false" default="">
		<cfargument name="Payment_Account" type="string" required="false" default="">

   		<cfscript>

			tmpStruct = structNew();
			tmpStruct.compID = arguments.compID;
			tmpStruct.compNameId = arguments.compNameId;
			tmpStruct.programID = arguments.programID;
			tmpStruct.compName = arguments.compName;
			tmpStruct.compUUID = arguments.compUUID;
			tmpStruct.GL_Account_ID = arguments.GL_Account_ID;
			tmpStruct.Claim_Mechanics = arguments.Claim_Mechanics;
			tmpStruct.Deduction_Account = arguments.Deduction_Account;
			tmpStruct.Payment_Account = arguments.Payment_Account;
		</cfscript>

		<cfreturn tmpStruct />

   </cffunction>

   <cffunction name="checkExists" output="false" returntype="boolean">

	  	<cfargument name="aCompToCheck" type="array" required="true" default="">
		<cfargument name="compID" type="string" required="true" default="">


   		<cfscript>

			doesExist = false;

			for (i=1; i lte ArrayLen(arguments.aCompToCheck); i = i+1)
			{
				if (not CompareNoCase(arguments.aCompToCheck[i].compUUID, arguments.compID))
					doesExist = true;
			}

		</cfscript>

		<cfreturn doesExist />

   </cffunction>

	<cffunction name="getActive" output="false" returntype="query">

		<cfargument name="profileId" required="false" default="" />

		<cfset lRestrictList = "" />

		<!--- get a list of comps to filter on based if a profile is passed --->
		<cfif trim(arguments.profileId) neq "">

			<cfset lRestrictList = CreateObject("component","components.programs.fixed.FixedComponentProfile").compIdsToFilter(arguments.profileId) />

		</cfif>
		<!--- Dev Note:KAL; 10229 :remove >2 logic for fixed price components   --->
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT  *
			FROM 	Program_Fixed_Component_Name
			WHERE 	Deleted = 0
			AND		Active = 1
			-- AND Program_Fixed_Component_Name_Id > 2
			<cfif trim(lRestrictList) neq "">
			AND		Program_Fixed_Component_Name_ID NOT IN (#lRestrictList#)
			</cfif>
			ORDER BY 	Program_Fixed_Component_Name
		</cfquery>

		<cfreturn qGetActiveComps />

   	</cffunction>

	<cffunction name="getComp" output="false" returntype="query">

   		<cfargument name="compId" required="false" default=0 />

		<cfquery name="qGetComp" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Program_Fixed_Component_Name
			WHERE 	Program_Fixed_Component_Name_ID = '#arguments.compId#'
		</cfquery>

		<cfreturn qGetComp />

   	</cffunction>


	<cffunction name="getInActive" output="false" returntype="query">

		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Program_Fixed_Component_Name
			WHERE 	Deleted = 0
			AND		Active = 0
			ORDER BY Program_Fixed_Component_Name
		</cfquery>

		<cfreturn qGetActiveComps />

   	</cffunction>

	<cffunction name="add" output="false" hint="Function used to add a new component.">

		<cfargument name="componentName" required="false" default="" />
		<cfargument name="externalID" required="false" default="" />
		<cfargument name="comptype" required="false" default="" />
		<cfargument name="operatingGroupId" required="false" default="0" />
		<cfargument name="allowanceCodeId" required="false" default="0" />
		<cfargument name="selectedTemplateIdList" required="false" default="" />
		<cfargument name="Accrual_On" required="false" default="0" />
		<cfargument name="Exclude_Brokerage" required="false" default="0" />
		<cfargument name="Floor_Pricing_On" required="false" default="0" />
		<cfargument name="Off_Invoice_On" required="false" default="0" />
		<cfargument name="User_ID" required="false" default="" />
		<cfargument name="GLList" required="false" default="" />
		<cfargument name="program_summary_display_name" required="false" default="" />
		<cfargument name="Deduction_Account" required="false" default="" />
		<cfargument name="Payment_Account" required="false" default="" />
		<cfargument name="FOB_PayeeType1_DiscountType" type="string" required="false" default="" />
		<cfargument name="FOB_PayeeType2_DiscountType" type="string" required="false" default="" />
		<cfargument name="FOB_PayeeType3_DiscountType" type="string" required="false" default="" />
		<cfargument name="Fixed_Price_Type" type="numeric" required="false" default="0" />
		<!--- 34392 --->
		<cfargument name="greatest_program_value" type="numeric" required="false" default="0" />
		<!---  D41867 :: Sysco  Update BB Expected Rate for Operator Deviated Programs.  CF Work START --->
		<cfargument name="Update_BB_Expected_Rate" required="false" default="0" />
		<cfargument name="Expected_Rate" required="false" default="0" />
		<cfargument name="Program_Pays_To" required="false" default="0" />
		<!---D41867 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work END --->
		<cfargument name="TemplatePaidToDefaultCFPages" required="false" default="" type="string"  />
		<cfargument name="TemplatePaidToDefaultRatesGrid" required="false" default="" type="string"  />
		<cfargument name="structTemplatePaidTo" required="false" default="structNew()" type="struct"  />

		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<cfargument name="DisplayID" required="false" default="0" />
		<cfargument name="DisplayDeductionAccount" required="false" default="0" />
		<cfargument name="DisplayPaymentAccount" required="false" default="0" />
		<!--- D58135 ::  Additional Component info displaye inside program END --->
		<cfargument name="FP_Type" required="false" default="0" />	<!--- 62455  --->
		<cfargument name="formulaPrice" required="false" default="0" />
		<cfargument name="ProgramLockTypeID" required="false" default="0" />
		<!---D79237 Fixed Price - OI and Redi START--->
		<cfargument name="Include_Second_Component" required="false" default="0" />
		<cfargument name="Second_Component_Name_ID" required="false" default="0" />
		<cfargument name="Second_Component_Payment_Type_ID" required="false" default="0" />
		<cfargument name="Second_Component_GL_Account_ID" required="false" default="0" />
		<cfargument name="Second_Component_Payment_Cycle_ID" required="false" default="0" />

		<cfargument name="TPO_Field" required="false" default="0" /> <!--- 95126 --->
		<cfargument name="TPO_Rate_Type" required="false" default="0" /> <!---95126 --->


		<cfargument name="Expected_Rate_Affect_Discount_Type" required="false" default="0" /> <!--- 91550 --->
		<cfargument name="Expected_Rate_Apply_All_Templates" required="false" default="0" /> <!---91550 --->
		<cfargument name="ExpectedRateTemplateList" required="false" default="0" /> <!---91550 --->

		<cfif arguments.Include_Second_Component EQ 0>
			<cfset arguments.Second_Component_Name_ID = 0>
			<cfset arguments.Second_Component_Payment_Type_ID = 0>
			<cfset arguments.Second_Component_GL_Account_ID = 0>
			<cfset arguments.Second_Component_Payment_Cycle_ID = 0>
		</cfif>
		<!---D79237 Fixed Price - OI and Redi END--->

		<cfset bCompNameExists = 0 />
		<cfset bProceedWithInsert = 1 />

		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT	Program_Fixed_Component_Name_ID, External_ID
			FROM	Program_Fixed_Component_Name
			WHERE	Program_Fixed_Component_Name = '#trim(arguments.componentName)#'
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
			<cfquery name="qGetActiveComps" datasource="#application.datasource#">
				SET NOCOUNT ON
				INSERT INTO	Program_Fixed_Component_Name
					(Program_Fixed_Component_Name,
					 Program_Summary_Display_Name,
					External_ID,Fixed_Component_Type,
					Operating_Group_ID,
					Allowance_Code_ID,
					Accrual_On,
					Exclude_Brokerage,
					Floor_Pricing_On,
					Off_Invoice_On,
					Deduction_Account,
					Payment_Account,
					Fixed_Price_Type,
					Last_Edited_By,
					Last_Edited_Date
					,Greatest_Program_Value  <!--- 34392 --->
					<!--- D41867 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work --->
					,Update_BB_Expected_Rate
					,Expected_Rate
					,Program_Pays_To
					<!--- D41867 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work --->
					<!--- D58135 ::  Additional Component info displaye inside program START--->
					,ID_on_ViewProgramPage
					,DeductionAccount_on_ViewProgramPage
					,PaymentAccount_on_ViewProgramPage
					<!--- D58135 ::  Additional Component info displaye inside program END--->
					,FP_Type <!--- 62455  --->
					,Formula_Pricing
					,Program_Lock_Type_ID
					,Include_Second_Component
					,Second_Component_Name_ID
					,Second_Component_Payment_Type_ID
					,Second_Component_GL_Account_ID
					,Second_Component_Payment_Cycle_ID
					,TPO_Field <!---95126 --->
					,TPO_Rate_Type <!---95126 --->
					,Expected_Rate_Affect_Discount_Type<!--- 91550--->
					,Expected_Rate_Apply_All_Templates<!--- 91550--->
					 )
				VALUES
					('#arguments.componentName#',
					 <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.program_summary_display_name#" />,
					'#arguments.externalID#',
					#arguments.compType#,
					<cfqueryparam value="#arguments.operatingGroupId#" cfsqltype="CF_SQL_INTEGER" null="#arguments.operatingGroupId EQ 0#">,
					<cfqueryparam value="#arguments.allowanceCodeId#" cfsqltype="CF_SQL_INTEGER" null="#arguments.allowanceCodeId EQ 0#">,
					<cfqueryparam value="#arguments.Accrual_On#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.Exclude_Brokerage#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.Floor_Pricing_On#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.Off_Invoice_On#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.Deduction_Account#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.Payment_Account#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.Fixed_Price_Type#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
					getdate()
					,<cfqueryparam value="#arguments.greatest_program_value#" cfsqltype="CF_SQL_BIT">  <!--- 34392 --->
					<!--- D41867 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work --->
					,<cfqueryparam value="#arguments.Update_BB_Expected_Rate#" cfsqltype="cf_sql_bit">
					,<cfqueryparam value="#arguments.Expected_Rate#" cfsqltype="CF_SQL_INTEGER">
					,<cfqueryparam value="#arguments.Program_Pays_To#" cfsqltype="CF_SQL_INTEGER">
					<!--- D41867 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work --->
					<!--- D58135 ::  Additional Component info displaye inside program START--->
					,<cfqueryparam value="#arguments.DisplayID#" cfsqltype="cf_sql_bit">
					,<cfqueryparam value="#arguments.DisplayDeductionAccount#" cfsqltype="cf_sql_bit">
					,<cfqueryparam value="#arguments.DisplayPaymentAccount#" cfsqltype="cf_sql_bit">
					<!--- D58135 ::  Additional Component info displaye inside program END--->
					,<cfqueryparam value="#arguments.FP_Type#" cfsqltype="CF_SQL_INTEGER">	<!--- 62455  --->
					,<cfqueryparam value="#arguments.formulaPrice#" cfsqltype="CF_SQL_INTEGER">
					,<cfqueryparam value="#arguments.ProgramLockTypeID#" cfsqltype="CF_SQL_INTEGER">
					,<cfqueryparam value="#arguments.Include_Second_Component#" cfsqltype="cf_sql_bit">
					,<cfqueryparam value="#arguments.Second_Component_Name_ID#" cfsqltype="CF_SQL_INTEGER">
					,<cfqueryparam value="#arguments.Second_Component_Payment_Type_ID#" cfsqltype="CF_SQL_INTEGER">
					,<cfqueryparam value="#arguments.Second_Component_GL_Account_ID#" cfsqltype="CF_SQL_INTEGER">
					,<cfqueryparam value="#arguments.Second_Component_Payment_Cycle_ID#" cfsqltype="CF_SQL_INTEGER">
					,<cfqueryparam value="#arguments.TPO_Field#" cfsqltype="CF_SQL_INTEGER"> <!--- 95126 --->
					,<cfqueryparam value="#arguments.TPO_Rate_Type#" cfsqltype="CF_SQL_INTEGER"> <!--- 95126 --->
					,<cfqueryparam value="#arguments.Expected_Rate_Affect_Discount_Type#" cfsqltype="CF_SQL_INTEGER"> <!--- 91550--->
					,<cfqueryparam value="#arguments.Expected_Rate_Apply_All_Templates#" cfsqltype="CF_SQL_INTEGER"> <!--- 91550--->
				)
				SELECT Program_Fixed_Component_Name_ID = @@IDENTITY
				SET NOCOUNT OFF
			</cfquery>
			<cfset templateManager.saveDiscountComponentTemplates(qGetActiveComps.Program_Fixed_Component_Name_ID, 1, arguments.selectedTemplateIdList,
				arguments.TemplatePaidToDefaultCFPages, arguments.TemplatePaidToDefaultRatesGrid, arguments.structTemplatePaidTo) />

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
					'#qGetActiveComps.Program_Fixed_Component_Name_ID#',
					1
				)
				</cfquery>
				</cfloop>
			</Cfif>

			<cfset application.oController.getObject(path="mvc.Models.Settings.FOBPriceIndicatorManager",name="FOBPriceIndicatorManager",bReload= 0) />
			<!--- save auto pay fob price indicator list for payee = distributor --->
			<cfset application.oFOBPriceIndicatorManager.saveProgramComponentFOBPriceIndicator(
					payeeTypeId = 1,
					discountTypeId = 1,
					componentNameId = qGetActiveComps.Program_Fixed_Component_Name_ID,
					FOBList = arguments.FOB_PayeeType1_DiscountType) />
			<!--- save auto pay fob price indicator list for payee = operator --->
			<cfset application.oFOBPriceIndicatorManager.saveProgramComponentFOBPriceIndicator(
					payeeTypeId = 2,
					discountTypeId = 1,
					componentNameId = qGetActiveComps.Program_Fixed_Component_Name_ID,
					FOBList = arguments.FOB_PayeeType2_DiscountType) />
			<!--- save auto pay fob price indicator list for payee = broker --->
			<cfset application.oFOBPriceIndicatorManager.saveProgramComponentFOBPriceIndicator(
					payeeTypeId = 3,
					discountTypeId = 1,
					componentNameId = qGetActiveComps.Program_Fixed_Component_Name_ID,
					FOBList = arguments.FOB_PayeeType3_DiscountType) />

					<cfif ! arguments.Expected_Rate_Apply_All_Templates>
						<cfloop list="#arguments.ExpectedRateTemplateList#" index="FirstParentID">
							<cfquery name="DeleteExpectedRateTemplate" datasource="#application.datasource#">
								INSERT INTO Program_Expected_Rate_Template_List (Discount_Type_ID, Program_Component_Name_ID, First_Parent_ID)
								VALUES (1, #arguments.compId#, #FirstParentID#)
							</cfquery>
						</cfloop>
					</cfif>

		</cfif>

		<cfreturn bCompNameExists />

   	</cffunction>

	<cffunction name="deactivate" output="false" hint="Function used to deactivate components.">

		<cfargument name="compIds" required="false" default="" />

		<cfquery datasource="#application.datasource#">
			UPDATE 	Program_Fixed_Component_Name
			SET		Active = 0
			WHERE	Program_Fixed_Component_Name_ID IN(#arguments.compIds#)
		</cfquery>

   	</cffunction>

	<cffunction name="activate" output="false" hint="Function used to activate components.">

		<cfargument name="compIds" required="false" default="" />

		<cfquery datasource="#application.datasource#">
			UPDATE 	Program_Fixed_Component_Name
			SET		Active = 1
			WHERE	Program_Fixed_Component_Name_ID IN(#arguments.compIds#)
		</cfquery>

   	</cffunction>

	<cffunction name="delete" output="false" hint="Function used to delete components.">

		<cfargument name="compIds" required="false" default="" />

		<cfquery datasource="#application.datasource#">
			UPDATE 	Program_Fixed_Component_Name
			SET		Deleted = 1
			WHERE	Program_Fixed_Component_Name_ID IN(#arguments.compIds#)
		</cfquery>

   	</cffunction>

	<cffunction name="update" output="false" hint="Function used to update components." returntype="boolean">

		<cfargument name="compId" required="false" default="" />
		<cfargument name="compName" required="false" default="" />
		<cfargument name="program_summary_display_name" required="false" default="" />
		<cfargument name="externalID" required="false" default="" />
		<cfargument name="compType" required="false" default="1" />
		<cfargument name="operatingGroupId" required="false" default="0" />
		<cfargument name="allowanceCodeId" required="false" default="0" />
		<cfargument name="selectedTemplateIdList" required="false" default="" />
		<cfargument name="Accrual_On" required="false" default="0" />
		<cfargument name="Exclude_Brokerage" required="false" default="0" />
		<cfargument name="Floor_Pricing_On" required="false" default="0" />
		<cfargument name="Off_Invoice_On" required="false" default="0" />
		<cfargument name="User_ID" required="false" default="" />
		<cfargument name="GLList" required="false" default="" />
		<cfargument name="Deduction_Account" required="false" default="" />
		<cfargument name="Payment_Account" required="false" default="" />
		<cfargument name="FOB_PayeeType1_DiscountType" type="string" required="false" default="" />
		<cfargument name="FOB_PayeeType2_DiscountType" type="string" required="false" default="" />
		<cfargument name="FOB_PayeeType3_DiscountType" type="string" required="false" default="" />
		<cfargument name="Fixed_Price_Type" type="numeric" required="false" default="1" />
		<!--- 34392 --->
		<cfargument name="greatest_program_value" type="numeric" required="false" default="0" />
		<!--- D41867 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work --->
		<cfargument name="Update_BB_Expected_Rate" required="false" default="0" />
		<cfargument name="Expected_Rate" required="false" default="0" />
		<cfargument name="Program_Pays_To" required="false" default="0" />
		<cfargument name="TemplatePaidToDefaultCFPages" required="false" default="" type="string"  />
		<cfargument name="TemplatePaidToDefaultRatesGrid" required="false" default="" type="string"  />
		<cfargument name="structTemplatePaidTo" required="false" default="structNew()" type="struct"  />

		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<cfargument name="DisplayID" required="false" default="0" />
		<cfargument name="DisplayDeductionAccount" required="false" default="0" />
		<cfargument name="DisplayPaymentAccount" required="false" default="0" />
		<!--- D58135 ::  Additional Component info displaye inside program END --->
		<cfargument name="FP_Type" required="false" default="0" />	<!--- 62455  --->
		<cfargument name="formulaPrice" required="false" default="0" />
		<cfargument name="ProgramLockTypeID" required="false" default="0" />
		<!---D79237 Fixed Price - OI and Redi START--->
		<cfargument name="Include_Second_Component" required="false" default="0" />
		<cfargument name="Second_Component_Name_ID" required="false" default="0" />
		<cfargument name="Second_Component_Payment_Type_ID" required="false" default="0" />
		<cfargument name="Second_Component_GL_Account_ID" required="false" default="0" />
		<cfargument name="Second_Component_Payment_Cycle_ID" required="false" default="0" />

		<cfargument name="TPO_Field" required="false" default="0" /> <!--- 95126 --->
		<cfargument name="TPO_Rate_Type" required="false" default="0" /> <!---95126 --->

		<cfargument name="Expected_Rate_Affect_Discount_Type" required="false" default="0" /> <!--- 91550 --->
		<cfargument name="Expected_Rate_Apply_All_Templates" required="false" default="0" /> <!---91550 --->
		<cfargument name="ExpectedRateTemplateList" required="false" default="0" /> <!---91550 --->

		<cfif arguments.Include_Second_Component EQ 0>
			<cfset arguments.Second_Component_Name_ID = 0>
			<cfset arguments.Second_Component_Payment_Type_ID = 0>
			<cfset arguments.Second_Component_GL_Account_ID = 0>
			<cfset arguments.Second_Component_Payment_Cycle_ID = 0>
		</cfif>
		<!---D79237 Fixed Price - OI and Redi END--->

			<cfif arguments.Update_BB_Expected_Rate EQ 0>
				<cfset arguments.Expected_Rate = 0>
				<cfset arguments.Program_Pays_To = 0>
			</cfif>
		<!--- D41867 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work --->

		<cfset bCompNameExists = 0 />
		<cfset bProceedWithUpdate = 1 />

		<!---check to see if the name already exists--->
		<cfquery name="qCheckCompNames" datasource="#application.datasource#">
			SELECT	*
			FROM	Program_Fixed_Component_Name
			WHERE	Program_Fixed_Component_Name = '#trim(arguments.compName)#'
			AND		Program_Fixed_Component_Name_ID != #arguments.compId#
			AND		deleted = 0
		</cfquery>

		<!---If the name exists then set does not exist to false--->
		<cfif qCheckCompNames.RecordCount>

			<cfset bCompNameExists = 1 />
			<cfset bProceedWithUpdate = 1 />

		</cfif>

		<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
		<!------ Check if another componet (any discountype) have teh same allowance code ----->
		<cfif bProceedWithUpdate EQ 1>
			<!------ going to re-use the code to get list of all component names for diffent discount types ----->
			<cfset discountTypeList = templateManager.getComponentDiscountTypeList() />
			<cfset qGetAllTemplateDiscountComponents = templateManager.getAllTemplateDiscountComponents(0, discountTypeList, 0,0,0,1) />
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
		</cfif>

		<cfif bProceedWithUpdate>
			<cfquery datasource="#application.datasource#">
				UPDATE 	Program_Fixed_Component_Name
				SET		Program_Fixed_Component_Name = '#arguments.compName#',
				        Program_Summary_Display_Name = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.program_summary_display_name#" />,
						Fixed_Component_Type = #arguments.comptype#,
						External_ID = '#arguments.externalID#',
						Operating_Group_ID = <cfqueryparam value="#arguments.operatingGroupId#" cfsqltype="CF_SQL_INTEGER" null="#arguments.operatingGroupId EQ 0#">,
						Allowance_Code_ID = <cfqueryparam value="#arguments.allowanceCodeId#" cfsqltype="CF_SQL_INTEGER" null="#arguments.allowanceCodeId EQ 0#">,
						Accrual_On = <cfqueryparam value="#arguments.Accrual_On#" cfsqltype="CF_SQL_INTEGER" >,
						Exclude_Brokerage = <cfqueryparam value="#arguments.Exclude_Brokerage#" cfsqltype="CF_SQL_INTEGER">,
						Floor_Pricing_On = <cfqueryparam value="#arguments.Floor_Pricing_On#" cfsqltype="CF_SQL_INTEGER">,
						Off_Invoice_On = <cfqueryparam value="#arguments.Off_Invoice_On#" cfsqltype="CF_SQL_INTEGER">,
						Deduction_Account = <cfqueryparam value="#arguments.Deduction_Account#" cfsqltype="CF_SQL_VARCHAR">,
						Payment_Account = <cfqueryparam value="#arguments.Payment_Account#" cfsqltype="CF_SQL_VARCHAR">,
						Fixed_Price_Type = <cfqueryparam value="#arguments.Fixed_Price_Type#" cfsqltype="CF_SQL_INTEGER">,
						Last_Edited_By = <cfqueryparam value="#arguments.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
						Last_Edited_Date = getdate()
						,Greatest_Program_Value = <cfqueryparam value="#arguments.greatest_program_value#" cfsqltype="CF_SQL_BIT">  <!--- 34392 --->
						<!--- D41867 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work --->
						,Update_BB_Expected_Rate = <cfqueryparam value="#arguments.Update_BB_Expected_Rate#" cfsqltype="cf_sql_bit">
						,Expected_Rate = <cfqueryparam value="#arguments.Expected_Rate#" cfsqltype="CF_SQL_INTEGER">
						,Program_Pays_To = <cfqueryparam value="#arguments.Program_Pays_To#" cfsqltype="CF_SQL_INTEGER">
						<!--- D41867 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work --->
						<!--- D58135 ::  Additional Component info displaye inside program START--->
						,ID_on_ViewProgramPage = <cfqueryparam value="#arguments.DisplayID#" cfsqltype="cf_sql_bit">
						,DeductionAccount_on_ViewProgramPage = <cfqueryparam value="#arguments.DisplayDeductionAccount#" cfsqltype="cf_sql_bit">
						,PaymentAccount_on_ViewProgramPage	= <cfqueryparam value="#arguments.DisplayPaymentAccount#" cfsqltype="cf_sql_bit">
						<!--- D58135 ::  Additional Component info displaye inside program END--->
						,FP_Type=<cfqueryparam value="#arguments.FP_Type#" cfsqltype="CF_SQL_INTEGER">	<!--- 62455  --->
						,Formula_Pricing=<cfqueryparam value="#arguments.formulaPrice#" cfsqltype="CF_SQL_INTEGER">
						,Program_Lock_Type_ID = <cfqueryparam value="#arguments.ProgramLockTypeID#" cfsqltype="CF_SQL_INTEGER">
						,Include_Second_Component = <cfqueryparam value="#arguments.Include_Second_Component#" cfsqltype="cf_sql_bit">
						,Second_Component_Name_ID = <cfqueryparam value="#arguments.Second_Component_Name_ID#" cfsqltype="CF_SQL_INTEGER">
						,Second_Component_Payment_Type_ID = <cfqueryparam value="#arguments.Second_Component_Payment_Type_ID#" cfsqltype="CF_SQL_INTEGER">
						,Second_Component_GL_Account_ID = <cfqueryparam value="#arguments.Second_Component_GL_Account_ID#" cfsqltype="CF_SQL_INTEGER">
						,Second_Component_Payment_Cycle_ID = <cfqueryparam value="#arguments.Second_Component_Payment_Cycle_ID#" cfsqltype="CF_SQL_INTEGER">
						,TPO_Field = <cfqueryparam value="#arguments.TPO_Field#" cfsqltype="CF_SQL_INTEGER"> <!--- 95126--->
						,TPO_Rate_Type = <cfqueryparam value="#arguments.TPO_Rate_Type#" cfsqltype="CF_SQL_INTEGER"> <!--- 95126--->
						,Expected_Rate_Affect_Discount_Type = <cfqueryparam value="#arguments.Expected_Rate_Affect_Discount_Type#" cfsqltype="CF_SQL_INTEGER"> <!--- 91550--->
						,Expected_Rate_Apply_All_Templates = <cfqueryparam value="#arguments.Expected_Rate_Apply_All_Templates#" cfsqltype="CF_SQL_INTEGER"> <!--- 91550--->
				WHERE	Program_Fixed_Component_Name_ID = #arguments.compId#
			</cfquery>

			<cfif len(trim(arguments.GLList)) GT 0>
				<cfloop list="#arguments.GLList#" index="GL_Account_ID">
					<cfquery name="DeletefromMapping" datasource="#application.datasource#">
					DELETE FROM GL_Component_Mapping
					WHERE GL_Account_ID = '#GL_Account_ID#'
					AND Component_Name_ID = '#arguments.compId#'
					AND Discount_Type_ID = 1
					</cfquery>
				</cfloop>
			</cfif>

			<cfset templateManager.saveDiscountComponentTemplates(arguments.compId, 1, arguments.selectedTemplateIdList,
				arguments.TemplatePaidToDefaultCFPages, arguments.TemplatePaidToDefaultRatesGrid, arguments.structTemplatePaidTo) />

			<cfset application.oController.getObject(path="mvc.Models.Settings.FOBPriceIndicatorManager",name="FOBPriceIndicatorManager",bReload= 0) />
			<!--- save auto pay fob price indicator list for payee = distributor --->
			<cfset application.oFOBPriceIndicatorManager.saveProgramComponentFOBPriceIndicator(
					payeeTypeId = 1,
					discountTypeId = 1,
					componentNameId = arguments.compId,
					FOBList = arguments.FOB_PayeeType1_DiscountType) />
			<!--- save auto pay fob price indicator list for payee = operator --->
			<cfset application.oFOBPriceIndicatorManager.saveProgramComponentFOBPriceIndicator(
					payeeTypeId = 2,
					discountTypeId = 1,
					componentNameId = arguments.compId,
					FOBList = arguments.FOB_PayeeType2_DiscountType) />
			<!--- save auto pay fob price indicator list for payee = broker --->
			<cfset application.oFOBPriceIndicatorManager.saveProgramComponentFOBPriceIndicator(
					payeeTypeId = 3,
					discountTypeId = 1,
					componentNameId = arguments.compId,
					FOBList = arguments.FOB_PayeeType3_DiscountType) />

					<cfif ! arguments.Expected_Rate_Apply_All_Templates>
						<cfquery name="GetTempTables" datasource="#application.datasource#">
							IF OBJECT_ID('tempdb..##tmp_Program_Expected_Rate_Template_List') IS NOT NULL
							DROP TABLE ##tmp_Program_Expected_Rate_Template_List

							CREATE TABLE ##tmp_Program_Expected_Rate_Template_List (FirstParentID INT)
						</cfquery>

						<cfloop list="#arguments.ExpectedRateTemplateList#" index="FirstParentID">
							<cfquery name="GetExpectedRateTemplate" datasource="#application.datasource#">
								INSERT INTO ##tmp_Program_Expected_Rate_Template_List (FirstParentID)
								VALUES (#FirstParentID#)
							</cfquery>
						</cfloop>

						<cfquery name="DeleteExpectedRateTemplate" datasource="#application.datasource#">
							DELETE
							FROM Program_Expected_Rate_Template_List
							WHERE Discount_Type_ID = 1
							AND Program_Component_Name_ID  = #arguments.compId#
							AND NOT EXISTS (SELECT 1
																							FROM ##tmp_Program_Expected_Rate_Template_List T
																							Where T.FirstParentID = Program_Expected_Rate_Template_List.First_Parent_ID)

								INSERT INTO Program_Expected_Rate_Template_List (Discount_Type_ID, Program_Component_Name_ID, First_Parent_ID)
								SELECT 1, #arguments.compId#, FirstParentID
								FROM ##tmp_Program_Expected_Rate_Template_List T
								WHERE NOT EXISTS (SELECT 1
																											FROM Program_Expected_Rate_Template_List
																											WHERE Program_Expected_Rate_Template_List.Discount_Type_ID = 1
																											AND Program_Expected_Rate_Template_List.Program_Component_Name_ID  = #arguments.compId#
																											AND T.FirstParentID = Program_Expected_Rate_Template_List.First_Parent_ID)

							</cfquery>

					</cfif>

		</cfif>

		<cfreturn bCompNameExists />

   	</cffunction>

	<cffunction name="canDelete" output="false" returntype="boolean" hint="Function used to verify if a component can be deleted or not.">

   		<cfargument name="nameID" type="numeric" required="false" default="" />

		<cfquery name="qCheckCompName" datasource="#application.datasource#">
			SELECT 	count(*) as count
			FROM 	Program_Fixed_Component
			WHERE 	Program_Fixed_Component_Name_ID = <cfqueryparam value="#arguments.nameID#" cfsqltype="CF_SQL_INTEGER" />
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

	<cffunction name="hasRules" output="false" returntype="boolean" hint="Function used to verify if a component has business rules or not.">

		<cfargument name="compId" type="numeric" required="false" default="" />

		<cfquery name="qCheckBusRules" datasource="#application.datasource#">
			SELECT 	Has_Rules
			FROM 	Program_fixed_Component_Name
			WHERE 	Program_fixed_Component_Name_ID = <cfqueryparam value="#arguments.compId#" cfsqltype="CF_SQL_INTEGER" />
			AND 	Deleted = 0
		</cfquery>

		<!---if Has_Rules eq 1 then set bHasRules to true--->
		<cfif qCheckBusRules.Has_Rules eq 1>
			<cfset bHasRules = 1 />
		<cfelse>
			<cfset bHasRules = 0 />
		</cfif>

		<cfreturn bHasRules />

	</cffunction>


	<cffunction name="getProgFixComp" output="false" returntype="query">

   		<cfargument name="ProgID" required="true" default=0 />
		<cfargument name="FixedComponentList" required="false" default="">
		<!--- Dev Note: KAL; 10229: remove >2 logic for fixed price components  --->
		<cfquery name="qgetProgFixComp" datasource="#application.datasource#">
			SELECT  *, N.Program_Fixed_Component_Name_ID,
					N.Fixed_Component_Type,
					N.Program_Fixed_Component_Name,
					C.Program_Fixed_Component_Id,
					C.Fixed_Component_Paid_to,
					C.GL_Account_ID,
					C.Claim_Mechanics
			FROM Program_Fixed_Component_Name N
			left JOIN Program_Fixed_Component C
					ON C.Program_Fixed_Component_Name_ID = N.Program_Fixed_Component_Name_ID
					AND C.Program_ID = <cfqueryparam value="#arguments.ProgID#" cfsqltype="CF_SQL_INTEGER" />
					AND C.Deleted = 0
			WHERE N.Deleted = 0
				AND N.Active = 1
			AND N.Program_Fixed_Component_Name_id is not null
			<cfif isdefined("arguments.FixedComponentList")>
			<cfif LIstlen(arguments.FixedComponentList) NEQ 0>
			and N.Program_Fixed_Component_Name_Id in (#arguments.FixedComponentList#)
			<cfelse>
			and 1=2
			</cfif>
			</cfif>
			ORDER BY N.Program_Fixed_Component_Name_ID, C.Program_Fixed_Component_Id

		</cfquery>

		<cfreturn qgetProgFixComp />

   	</cffunction>

<!--- 	<cffunction name="getProgFixCompProd" output="false" returntype="query">

   		<cfargument name="ProgID" required="true" default=0 />

		<cfquery name="qgetProgFixCompProd" datasource="#application.datasource#">
			SELECT	distinct CP.BSA_Foodservice_Items_Master_ID, description
				FROM	Contract_Products CP
					INNER JOIN dbo.Program_Fixed_Price_Product_Data FD ON
						FD.Contract_Products_ID = CP.Contract_Products_ID AND
						FD.Deleted = 0
					INNER JOIN BSA_Foodservice_Items_Master I ON
						I.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID AND
						I.deleted = 0
			WHERE
						CP.Deleted = 0 AND
						CP.Contract_Main_ID =  <cfqueryparam value="#arguments.ProgID#" cfsqltype="CF_SQL_INTEGER" />
						AND
						CP.product_type_id =1
		</cfquery>

		<cfreturn qgetProgFixCompProd />

   	</cffunction> --->

	<cffunction name="getProgFixCompProd" output="false" returntype="query">

   		<cfargument name="ProgID" required="true" default=0 />
		<cfargument name="Product_List" required="true" default="" />

		<cfquery name="qgetProgFixCompProd" datasource="#application.datasource#">
			SELECT	distinct BSA_Foodservice_Items_Master_ID, description
				FROM	BSA_Foodservice_Items_Master I
			WHERE
						I.Deleted = 0 AND
			<CFIF arguments.Product_List EQ "">
				1=2
			<CFELSE>
				I.BSA_Foodservice_Items_Master_ID
				IN (#ListQualify(arguments.Product_List, "'", ",")#)
			</cfif>
		</cfquery>

		<cfreturn qgetProgFixCompProd />

   	</cffunction>


	<cffunction name="getFixedData" output="false" returntype="struct">

   		<cfargument name="ProgID" required="true" default=0 />
		<cfargument name="Product_List" required="true" default="" />
		<cfargument name="FixedComponentList" required="true" default="" />

		<cfset qgetProgFixComp = this.getProgFixComp(arguments.ProgID,arguments.FixedComponentList) />
		<cfset qgetProgFixCompProd = this.getProgFixCompProd(arguments.ProgID,arguments.Product_List) />
		<cfset fixedData = StructNew()>
		<Cfset fixedData.aComp = ArrayNew(1)>
		<Cfset fixedData.aProd = ArrayNew(1)>

		<cfloop query="qgetProgFixComp">
			<cfset fixedData.aComp[#evaluate(qgetProgFixComp.currentrow)#] = StructNew()>
			<cfset fixedData.aComp[#evaluate(qgetProgFixComp.currentrow)#].hasRules = this.getComp(qgetProgFixComp.Program_Fixed_Component_Name_ID).has_Rules>
			<cfset fixedData.aComp[#evaluate(qgetProgFixComp.currentrow)#].rulesRequired = this.getComp(qgetProgFixComp.Program_Fixed_Component_Name_ID).rule_required>
			<cfset fixedData.aComp[#evaluate(qgetProgFixComp.currentrow)#].CompUUID = qgetProgFixComp.currentrow>
			<cfset fixedData.aComp[#evaluate(qgetProgFixComp.currentrow)#].CompNameId = qgetProgFixComp.Program_Fixed_Component_Name_ID>
			<cfset fixedData.aComp[#evaluate(qgetProgFixComp.currentrow)#].componentPaidTo = qgetProgFixComp.Fixed_Component_Paid_to>
			<cfset fixedData.aComp[#evaluate(qgetProgFixComp.currentrow)#].GL_Account_ID = qgetProgFixComp.GL_Account_ID>
			<cfset fixedData.aComp[#evaluate(qgetProgFixComp.currentrow)#].Claim_Mechanics = qgetProgFixComp.Claim_Mechanics>
			<cfset fixedData.aComp[#evaluate(qgetProgFixComp.currentrow)#].Vendor_Master_ID = qgetProgFixComp.Vendor_Master_ID>
		</cfloop>


		<cfloop query="qgetProgFixCompProd">
			<cfset fixedData.aProd[#evaluate(qgetProgFixCompProd.currentrow)#] = StructNew()>
			<cfset fixedData.aProd[#evaluate(qgetProgFixCompProd.currentrow)#].masterItemId = qgetProgFixCompProd.BSA_Foodservice_Items_Master_ID>
			<cfset fixedData.aProd[#evaluate(qgetProgFixCompProd.currentrow)#].description = qgetProgFixCompProd.description>
		</cfloop>

		<cfreturn fixedData />

   	</cffunction>


	<cffunction name="getFixProdRule" output="false" returntype="numeric">

   		<cfargument name="ProdID" required="true" default=0 />
		<cfargument name="compID" required="true" default=0 />
		<cfargument name="progID" required="true" default=0 />
		<cfargument name="paidTo" required="true" default=0 />

		<cfquery name="qgetFixProd" datasource="#application.datasource#">
			SELECT	FD.Program_Fixed_Component_Name_Rule_ID
				FROM	dbo.Program_Fixed_Price_Product_Data FD
					INNER JOIN Contract_Products CP ON
						FD.Contract_Products_ID = CP.Contract_Products_ID AND
						FD.Deleted = 0
					INNER JOIN Program_Fixed_Component C
						ON C.Program_ID = CP.Contract_Main_ID
						AND C.Program_Fixed_Component_ID = FD.Program_Fixed_Component_ID
						 and C.DELETED = 0
					INNER JOIN Program_Fixed_Component_Name N
						ON N.Program_Fixed_Component_Name_ID = C.Program_Fixed_Component_Name_ID
						and N.Deleted = 0
					Inner Join Program_Fixed_Component_Name_Rule FNR
					  ON FNR.Program_Fixed_Component_Name_ID = N.Program_Fixed_Component_Name_ID
					Inner Join Program_Fixed_Component_Rule FR
						ON FR.Program_Fixed_Component_Rule_ID = FNR.Program_Fixed_Component_Rule_ID

			WHERE
						CP.Deleted = 0
						AND FR.deleted = 0
						AND FD.deleted = 0
						AND FNR.deleted = 0
						AND CP.Contract_Main_ID =  <cfqueryparam value="#arguments.ProgID#" cfsqltype="CF_SQL_INTEGER" />
						AND CP.product_type_id =1
						AND N.Program_Fixed_Component_Name_ID =  <cfqueryparam value="#arguments.compID#" cfsqltype="CF_SQL_INTEGER" />
						AND CP.BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#arguments.ProdID#"/>
						AND Fixed_component_paid_to = <cfqueryparam value="#arguments.paidTo#"/>
		</cfquery>
		<cfif not isnumeric(qgetFixProd.Program_Fixed_Component_Name_Rule_ID)>
			<cfset theResult = 0>
		 <cfelse>
		 	<cfset theResult = qgetFixProd.Program_Fixed_Component_Name_Rule_ID>
		</cfif>
		<cfreturn theResult />

   	</cffunction>

	<cffunction name="getdistributors" output="false" returntype="query">
   	<cfargument name="ProgramID" required="true" default=0 />
	<cfargument name="dist_list" required="false" default=0 />
	<cfargument name="from_distpage" required="false" default=0 /><!--- Probably not being used now --->
	<cfquery name="qgetdistributors" datasource="#application.datasource#">
		select distinct contract_distributors.bsa_foodservice_customers_id,
		shr_ship_to,name from
		contract_distributors
		inner join bsa_foodservice_customers on
		bsa_foodservice_customers.bsa_foodservice_customers_id =
		contract_distributors.bsa_foodservice_customers_id
		where contract_distributors.deleted = 0
		and contract_distributors.contract_main_id = '#arguments.ProgramID#'
		order by name asc
	</cfquery>
		<cfreturn qgetdistributors />
   	</cffunction>

	<cffunction name="getproducts" output="false" returntype="query">
   	<cfargument name="ProgramID" required="true" default=0 />
	<cfargument name="list" required="false" default="">
	<cfargument name="sort_by" required="false" default="name" />
	<cfargument name="sort_order" required="false" default="asc" />
	<cfargument name="from_distpage" required="false" default=0 /><!--- Probably not being used now --->
	<cfargument name="componentId" type="numeric" required="false" default="0" />
	<cfargument name="paidTo" type="numeric" required="false" default="0" />

	<cfquery name="qgetproducts" datasource="#application.datasource#">
		select item,description,shr_ship_to,name,
		isnull(Delivered_Price,0.0000) as Delivered_Price,
		isnull(Freight_Rate,0.0000) as Freight_Rate,
		isnull(FOB_Price,0.0000) as FOB_Price,
		bsa_foodservice_items_master.bsa_foodservice_items_master_id,
		contract_distributors.bsa_foodservice_customers_id
		from bsa_foodservice_items_master
		inner join contract_distributors on
		contract_distributors.contract_main_id = '#arguments.programId#'
		and contract_distributors.deleted = 0
		inner join bsa_foodservice_customers on
		bsa_foodservice_customers.bsa_foodservice_customers_id =
		contract_distributors.bsa_foodservice_customers_id
		left join Program_Fixed_Freight_Rates on
		Program_Fixed_Freight_Rates.product_id =
		bsa_foodservice_items_master.bsa_foodservice_items_master_id
		and Program_Fixed_Freight_Rates.Component_Name_Id = #arguments.componentId#
		and Program_Fixed_Freight_Rates.Paid_To = #arguments.paidTo#
		and Program_Fixed_Freight_Rates.deleted = 0
		and Program_Fixed_Freight_Rates.customer_id =
		contract_distributors.bsa_foodservice_customers_id
		and Program_Fixed_Freight_Rates.program_id =
		contract_distributors.contract_main_id
		where  bsa_foodservice_items_master_id in (#ListQualify(arguments.list, "'", ",")#)
		order by #arguments.sort_by# #arguments.sort_order#
	</cfquery>
		<cfreturn qgetproducts />
   	</cffunction>

	<cffunction name="getproductsrates" output="false" returntype="query">
   	<cfargument name="ProgramID" required="true" default=0 />
	<cfargument name="product_list" required="true" default="">
	<cfquery name="qgetproductsrates" datasource="#application.datasource#">
		select distinct bsa_foodservice_items_master_id,customer_id,
		isnull(Delivered_Price,0.0000) as Delivered_Price,
		isnull(Freight_Rate,0.0000) as Freight_Rate,
		isnull(FOB_Price,0.0000) as FOB_Price
		from bsa_foodservice_items_master
		left join Program_Fixed_Freight_Rates
		on bsa_foodservice_items_master.bsa_foodservice_items_master_id =
		Program_Fixed_Freight_Rates.product_id
		and Program_Fixed_Freight_Rates.deleted = 0
		and Program_Fixed_Freight_Rates.program_id = '#arguments.ProgramID#'
		where  bsa_foodservice_items_master_id in (#ListQualify(arguments.Product_List, "'", ",")#)
	</cfquery>
		<cfreturn qgetproductsrates />
   	</cffunction>

	<cffunction name="checkifprodmatchinfreighttable" output="false" returntype="string">
   	<cfargument name="ProgramID" required="true" default=0 />
	<cfargument name="prod_list" required="true" default="">
	<cfset productssmatch = "false">
	<cfquery name="qcheckifprodmatchinfreighttable" datasource="#application.datasource#">
		select distinct bsa_foodservice_items_master_id
		from bsa_foodservice_items_master
		where bsa_foodservice_items_master_id in
		(#ListQualify(arguments.prod_list, "'", ",")#)
		and bsa_foodservice_items_master_id not in
		(select distinct product_id from
		Program_Fixed_Freight_Rates
		where Program_Fixed_Freight_Rates.deleted = 0
		and Program_Fixed_Freight_Rates.program_id = '#arguments.ProgramID#')
	</cfquery>
	<cfif qcheckifprodmatchinfreighttable.recordcount GT 0>
		<cfset productssmatch = "false">
	<cfelse>
		<cfset productssmatch = "true">
	</cfif>
		<cfreturn productssmatch />
   	</cffunction>

	<cffunction name="FREIGHTRATESAPPLIED" output="false" returntype="string">
   	<cfargument name="ProgramID" required="true" default=0 />
	<cfargument name="componentId" type="numeric" required="false" default="0" />
	<cfargument name="paidTo" type="any" required="false" default="0" />

	<cfset var paidToArgs = 0 />

	  <cfif arguments.paidTo neq "">
		 <cfset paidToArgs = arguments.paidTo />
	  </cfif>

	<cfquery name="qFREIGHTRATESAPPLIED" datasource="#application.datasource#">
		select distinct product_id from
		Program_Fixed_Freight_Rates
		where Program_Fixed_Freight_Rates.deleted = 0
		and Program_Fixed_Freight_Rates.program_id = '#arguments.ProgramID#'
		<cfif isDefined('arguments.componentId') and arguments.componentId neq 0>
		and Program_Fixed_Freight_Rates.Component_Name_Id = #arguments.componentId#
		and Program_Fixed_Freight_Rates.Paid_To = #paidToArgs#
		 </cfif>
	</cfquery>
	<cfif qFREIGHTRATESAPPLIED.recordcount GT 0>
		<cfset freightapplied = 1>
	<cfelse>
		<cfset freightapplied = 0>
	</cfif>
		<cfreturn freightapplied />
   	</cffunction>


	<cffunction name="isNewComponent" returntype="boolean"
				output="false" access="public"
				displayname="isNewComponent"
				description="Dev Note 12293 Ben: Checks to see if this component exists on the
					         program">

	  <cfargument name="programId" required="true" type="numeric" />
	  <cfargument name="componentId" required="true" type="numeric" />
	  <cfargument name="paidTo" type="any" required="true" default="0" />

	  <cfset var doesComponentExist = "" />
	  <cfset var componentIsNew = false />
	  <cfset var paidToArgs = 0 />

	  <cfif arguments.paidTo neq "">
		 <cfset paidToArgs = arguments.paidTo />
	  </cfif>

	  <cfquery name="doesComponentExist" datasource="#application.datasource#">
	    select * from
		Program_Fixed_Freight_Rates
		where Program_Fixed_Freight_Rates.deleted = 0
		and Program_Fixed_Freight_Rates.program_id = #arguments.ProgramID#
		and Component_Name_Id = #arguments.componentId#
		and Paid_To = #paidToArgs#
	  </cfquery>

	   <cfif doesComponentExist.RecordCount>
	    <cfset componentIsNew = true />
	   </cfif>

	   <cfreturn componentIsNew />
	</cffunction>

	<cffunction name="deleteComponent" access="public" output="false"
				returntype="void" displayname="deleteComponent">

	  <cfargument name="componentId" type="numeric" required="true" />
	  <cfargument name="programId" type="numeric" required="true" />
	  <cfargument name="paidTo" type="any" required="true" default="0" />

	  <cfset var delComponent = "" />
	  <cfset var paidToArgs = 0 />

	  <cfif arguments.paidTo neq "">
		 <cfset paidToArgs = arguments.paidTo />
	  </cfif>

	  <cfquery name="delComponent" datasource="#application.datasource#">
	  	Update Program_Fixed_Freight_Rates
	  	Set Deleted = 1
	  	Where Component_Name_Id = #arguments.componentId#
	  	And   program_id = #arguments.programId#
	  	And   Paid_To = #paidToArgs#
	 </cfquery>

	</cffunction>

	<cffunction name="getFixedComponentType" output="false" returntype="query">

	<cfquery name="qrygetFixedComponentType" datasource="#application.datasource#">
		SELECT Delivery_Type_ID,Delivery_Type_Desc
		FROM Delivery_Type
		WHERE Deleted = 0
		ORDER BY Delivery_Type_Desc
	</cfquery>

		<cfreturn qrygetFixedComponentType />
   	</cffunction>

	<!--- If any of the fixed component types are either Delivered or FOBDC, then the program template is a
		  freight program template --->
	<cffunction name="getIsFreightProgram" output="false" returntype="boolean">

	<cfargument name="Program_Fixed_Component_Name_ID" type="string" required="true" />
		<cfif trim(Program_Fixed_Component_Name_ID) NEQ ''>
			<cfquery name="qryIsFreightProgram" datasource="#application.datasource#">
				SELECT
					CASE
						WHEN Fixed_Component_Type IN (1,4) THEN 1
						ELSE
						0
					END
						As IsFreightComponent

				FROM Program_Fixed_Component_Name
				WHERE Program_Fixed_Component_Name_ID IN (#arguments.Program_Fixed_Component_Name_ID#)
			</cfquery>

				<cfset Is_Freight_Program = 0>

				<cfloop query="qryIsFreightProgram">
					<cfif IsFreightComponent eq 1>
						<cfset Is_Freight_Program = 1>
						<cfbreak>
					</cfif>
				</cfloop>
		<cfelse>
			<cfset Is_Freight_Program = 0>
		</cfif>

		<cfreturn Is_Freight_Program />
   	</cffunction>

	<!---
		From the list of fixed component name id provided,
		find out if any of then are are either Delivered or FOBDC,
		also identify if there are just FOBDC(4) or doe sit have DEL(1)
	--->
	<cffunction name="GetFreightComponentType" output="false" returntype="boolean">
		<cfargument name="Program_Fixed_Component_Name_ID_List" type="string" required="true" />

		<cfquery name="qGetFreightComponentType" datasource="#application.datasource#">
			SELECT DISTINCT Fixed_Component_Type
			FROM 	Program_Fixed_Component_Name
			WHERE 	Program_Fixed_Component_Name_ID IN (<cfqueryparam value="#arguments.Program_Fixed_Component_Name_ID_List#" cfsqltype="cf_sql_varchar" list="true">)
			AND		Fixed_Component_Type IN (1,4)
		</cfquery>

		<cfset FreightComponentType = 0 /> <!--- type=none ---->
		<cfif qGetFreightComponentType.RecordCount>
			<cfset FreightComponentType = 4 /> <!--- type=fob dc ---->
			<cfloop query="qGetFreightComponentType">
				<cfif Fixed_Component_Type eq 1>
					<cfset FreightComponentType = 1 /> <!--- type=del ---->
					<cfbreak>
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn FreightComponentType />
   	</cffunction>

   	<cffunction name="GetFreightComponentTypeRFP" output="false" returntype="boolean">	
		<cfargument name="Program_Fixed_Component_Name_ID_List" type="string" required="true" />

		<cfquery name="qGetFreightComponentType" datasource="#application.datasource#">
			SELECT DISTINCT Fixed_Component_Type
			FROM 	Program_Fixed_Component_Name
			WHERE 	Program_Fixed_Component_Name_ID IN (<cfqueryparam value="#arguments.Program_Fixed_Component_Name_ID_List#" cfsqltype="cf_sql_varchar" list="true">)                     
			AND		Fixed_Component_Type IN (5,6,7,8,9)
		</cfquery>

		<cfset FreightComponentType = 0 /> <!--- type=none ---->
		<cfif qGetFreightComponentType.RecordCount>
			<cfset FreightComponentType = qGetFreightComponentType.Fixed_Component_Type /> 
			<!--- <cfset FreightComponentType = 8 /> ---Blended Delivered Freight Matrix
			<cfloop query="qGetFreightComponentType">
				<cfif Fixed_Component_Type eq 9>
					<cfset FreightComponentType = 9 /> --- Non Blended Delivered Freight Matrix 
					<cfbreak>
				</cfif>
			</cfloop> --->
		</cfif>
		<cfreturn FreightComponentType />
   	</cffunction>

	<!--- Set the program template to be a "freight" template or not --->
	<cffunction name="SetIsFreightProgram" output="false">

	<cfargument name="ProgramControl_Panel_Options_ID" type="numeric" required="true" />
	<cfargument name="IsFreightProgram" type="numeric" required="true" />
	<cfquery name="qrySetIsFreightProgram" datasource="#application.datasource#">
		UPDATE Program_Control_Panel_Options
		SET Freight_Program = #arguments.IsFreightProgram#
		WHERE ProgramControl_Panel_Options_ID = #arguments.ProgramControl_Panel_Options_ID#
	</cfquery>

   	</cffunction>

	<cffunction name="getFixedPriceDetails" output="false" returntype="query">
	   	<cfargument name="ProgramID" required="true" type="numeric" />
		<cfargument name="bFreight" required="false" type="Boolean" default="0" />
		<cfargument name="Distributor_Id" required="false" type="string" default="" />

		<cfquery name="qryFixedPriceDetails" datasource="#application.datasource#">
		SELECT DISTINCT
			Program_Fixed_Component_Name.Program_Fixed_Component_Name_Id
			,Program_Fixed_Component_Name.Program_Fixed_Component_Name
			,Program_Fixed_Component_Name.Fixed_Component_Type
			,Delivery_Type.Delivery_Type_Desc
			,IM.Item
			,IM.BSA_Foodservice_Items_Master_ID
			,IM.Description
			,ISNULL(Program_Fixed_Price_Product_Data.Fixed_Price_Value, 0) as Fixed_Price_Value
			,ISNULL(IM.Gross_Weight, 0) as Gross_Weight
			,ISNULL(IM.Net_Weight, 0) as Net_Weight
			,Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID
			<cfif bFreight>
				,ISNULL(CONVERT(Decimal(20,2),dbo.getItemOBF(OBF.OBF_Rate,IM.BSA_Foodservice_Items_Master_Id)), 0) As OBF_Rate_DB
			</cfif>
			FROM Program_Fixed_Price_Product_Data
			INNER JOIN contract_products
			ON Program_Fixed_Price_Product_Data.contract_products_id = contract_products.contract_products_id
			AND Program_Fixed_Price_Product_Data.program_id = contract_products.contract_main_id
			INNER JOIN BSA_Foodservice_Items_Master IM
			ON IM.BSA_Foodservice_Items_Master_ID = contract_products.BSA_Foodservice_Items_Master_ID
			INNER JOIN Program_Fixed_Component
			ON Program_Fixed_Component.Program_Fixed_Component_Id =
			Program_Fixed_Price_Product_Data.Program_Fixed_Component_Id
			INNER JOIN Program_Fixed_Component_Name ON
			Program_Fixed_Component_Name.Program_Fixed_Component_Name_Id = Program_Fixed_Component.Program_Fixed_Component_Name_Id
			INNER JOIN Delivery_Type
			ON Program_Fixed_Component_Name.Fixed_Component_Type = Delivery_Type.Delivery_Type_ID
			<cfif bFreight>
				LEFT Join Class_Code CC ON
					CC.Class_Code_Id = IM.Class_Code_Id
				LEFT JOIN Program_Distributor_Freight PDF ON
					PDF.Program_ID = <cfqueryparam value="#arguments.ProgramID#" cfsqltype="cf_sql_integer"> AND
					PDF.Distributor_ID = <cfqueryparam value="#arguments.Distributor_Id#" cfsqltype="cf_sql_idstamp" > AND
					PDF.Deleted = 0
				LEFT JOIN Customer_Warehouse_Bracket CWB ON
								CWB.Distributor_ID = '#arguments.Distributor_Id#'
				LEFT JOIN Outbound_Freight_Rate OBF ON
					OBF.Warehouse_Master_ID = PDF.Warehouse_Master_ID AND
					OBF.Freight_Bracket_Setting_ID  = CWB.Freight_Bracket_Setting_ID AND
					OBF.Product_Attribute_Code = CC.Class_Code
			</cfif>
			WHERE Contract_Products.Contract_Main_ID = <cfqueryparam value="#arguments.ProgramID#" cfsqltype="cf_sql_integer">
			AND Contract_Products.Deleted = 0
			AND Program_Fixed_Price_Product_Data.Deleted = 0
			AND Contract_Products.Product_Type_ID = 1
			<!--- Get it only for Delivered and FOBDC --->
			AND Program_Fixed_Component_Name.Fixed_Component_Type IN (1,4)
			AND Program_Fixed_Component.Deleted = 0
			ORDER BY Program_Fixed_Component_Name.Program_Fixed_Component_Name_Id,IM.Item
		</cfquery>

			<cfreturn qryFixedPriceDetails />
	</cffunction>

	<cffunction name="getProgramFixedComponentNames" output="false" returntype="query">
		<cfargument name="arAllowList" required="true" type="array">
		<cfargument name="Discount_Fixed_Prices_Freight" required="false" type="numeric" default="0">
		<cfargument name="EzButton_Disable" required="false" type="boolean" default="0">
		<cfargument name="EZ_Fixed_Comp_Ids" required="false" type="string" default="">
		<cfargument name="programID" required="false" type="string" default="">

		<cfset var i = 0>
		<cfset var arAllowListLen = ArrayLen(arguments.arAllowList)>

		<cfquery name="dropTempTable" datasource="#application.datasource#">
		IF OBJECT_ID('tempdb..##tmp_Fixed_Comp_List') IS NOT NULL
		DROP TABLE ##tmp_Fixed_Comp_List
		</cfquery>

		<cfquery name="local.GetFixedComponentNames" datasource="#application.datasource#">
	        SELECT 	DISTINCT Program_Fixed_Component_Name.*,
					Allowance_Code.Allowance_Code_Number, Allowance_Code.Allowance_Code_Desc,
					(SELECT TOP 1 GL_Component_Mapping.GL_Account_ID
					   FROM GL_Component_Mapping
					  WHERE GL_Component_Mapping.Component_Name_ID = Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID
								AND GL_Component_Mapping.Discount_Type_ID = 1
								AND GL_Account_ID IS NOT NULL
					) AS GL_Account_ID
			INTO ##tmp_Fixed_Comp_List
			FROM 	Program_Fixed_Component_Name
					LEFT JOIN Allowance_Code ON	Allowance_Code.Allowance_Code_ID = Program_Fixed_Component_Name.Allowance_Code_ID
					/* Get the GL_Code_Account_ID for the component to check whether validation for
						required GL_Code_Account_ID is required or not
						*/
					LEFT JOIN GL_Component_Mapping ON GL_Component_Mapping.Component_Name_ID = Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID
													AND GL_Component_Mapping.Discount_Type_ID = 1
			WHERE 	Program_Fixed_Component_Name.Active = <cfqueryparam value="1">
					AND 	Program_Fixed_Component_Name.Deleted =  <cfqueryparam value="0">
					<cfif arguments.Discount_Fixed_Prices_Freight EQ 1>
						AND Program_Fixed_Component_Name.Fixed_Component_Type = 3
					<cfelse>
						AND Program_Fixed_Component_Name.Fixed_Component_Type != 3
					</cfif>
					<cfif appSettings.get_Setting('Forbid_Same_Component_Same_Pays_To_In_Program') EQ '1'>
					AND Program_Fixed_Component_Name_ID NOT IN (SELECT Program_Fixed_Component_Name_ID FROM dbo.Program_Fixed_Component
					WHERE program_ID  = '#arguments.programID#' AND Deleted = 0)
					</cfif>
					<cfloop from="1" to="#arAllowListLen#" index="i">
						<cfset lAllowList = arguments.arAllowList[i] />
						<cfif Len(lAllowList) EQ 0>
							AND 	1=2
						<cfelse>
							AND		Program_Fixed_Component_Name_ID IN (#lAllowList#)
						</cfif>
					</cfloop>

					<cfif arguments.EzButton_Disable EQ 1>
						<cfif Len(arguments.EZ_Fixed_Comp_Ids) EQ 0>
							AND		1 = 2
						<cfelse>
							and Program_Fixed_Component_Name_ID IN (#arguments.EZ_Fixed_Comp_Ids#)
						</cfif>
					</cfif>
			<!--- Dev Note(79237) - Exclude the 2nd (Child) component, if it is already a 2nd component of any component on the program. --->
			SELECT * FROM ##tmp_Fixed_Comp_List
			WHERE Program_Fixed_Component_Name_ID NOT IN
			(
				SELECT DISTINCT Second_Component_Name_ID
				FROM ##tmp_Fixed_Comp_List
			)
			ORDER BY Program_Fixed_Component_Name
		</cfquery>

		<cfreturn local.GetFixedComponentNames>
	</cffunction>

<!---61605 : Event error on fixed price save when revision setting for UOM change is OFF START--->
	<cffunction name="getParentProgProductUOM" output="false" returntype="string">

   		<cfargument name="ParentProgID" required="true" default=0 />
		<cfargument name="ProductID" required="true" default="" />

		<cfquery name="qgetParentProgProductUOM" datasource="#application.datasource#">
			SELECT      		Unit_Of_Measure_ID
			FROM  				Contract_Products
			INNER JOIN  	dbo.Program_Fixed_Price_Product_Data
			ON 					Program_Fixed_Price_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
			AND 				Program_Fixed_Price_Product_Data.Deleted = 0
			WHERE 				Contract_Products.Deleted = 0
			AND 				Contract_Products.Contract_Main_ID =  <cfqueryparam value="#arguments.ParentProgID#" cfsqltype="cf_sql_integer">
			AND 				Contract_Products.product_type_id = 1
			AND 				Contract_Products.BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#arguments.ProductID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<cfreturn qgetParentProgProductUOM.Unit_Of_Measure_ID>
	</cffunction>
<!---61605 : Event error on fixed price save when revision setting for UOM change is OFF END--->
<!--- 91550 :: Enhancement: Template-specific Expected Rate Adjustments START --->
<cffunction name="getExpectedRateTemplates" returntype="query" output="false">
	<cfargument name="CompID" type="numeric" required="true" default="0">

	<cfquery name="qGetFixedComponentData" datasource="#application.datasource#">
		SELECT First_Parent_ID
		FROM Program_Expected_Rate_Template_List
		WHERE Discount_Type_ID = 1
		AND Program_Component_Name_ID = #arguments.CompID#
	</cfquery>
	<cfreturn qGetFixedComponentData/>
	</cffunction>
<!--- 91550 :: Enhancement: Template-specific Expected Rate Adjustments END --->
</cfcomponent>