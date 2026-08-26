<cfcomponent>

   <cffunction name="set" output="false" returntype="struct">

	  	<cfargument name="compID" type="string" required="true" default="">
		<cfargument name="compNameId" type="string" required="true" default="">
		<cfargument name="programID" type="numeric" required="true" default=0>
		<cfargument name="compName" type="string" required="true" default="">
		<cfargument name="compUUID" type="string" required="true" default="#CreateUUID()#">

   		<cfscript>

			tmpStruct = structNew();
			tmpStruct.compID = arguments.compID;
			tmpStruct.compNameId = arguments.compNameId;
			tmpStruct.programID = arguments.programID;
			tmpStruct.compName = arguments.compName;
			tmpStruct.compUUID = arguments.compUUID;

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

		<cfset useLakebaseForqGetActiveComps = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sum_name")>
<cfif useLakebaseForqGetActiveComps>
	<cftry>
		<cfset qGetActiveComps = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_lump_sum_name", {
				"deleted" = "eq.0",
				"active" = "eq.1",
				"order" = "program_lump_sum_name.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetActiveComps = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetActiveComps>
<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Program_Lump_Sum_Name
			WHERE 	Deleted = 0
			AND		Active = 1
			ORDER BY 	Program_Lump_Sum_Name
		</cfquery>
</cfif>

		<cfreturn qGetActiveComps />

   	</cffunction>

	<cffunction name="getComp" output="false" returntype="query">

   		<cfargument name="compId" required="false" default=0 />

		<cfset useLakebaseForqGetComp = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sum_name")>
<cfif useLakebaseForqGetComp>
	<cftry>
		<cfset qGetComp = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_lump_sum_name", {
				"program_lump_sum_name_id" = "eq.#arguments.compId#"
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
			FROM 	Program_Lump_Sum_Name
			WHERE 	Program_Lump_Sum_Name_ID = #arguments.compId#
		</cfquery>
</cfif>

		<cfreturn qGetComp />

   	</cffunction>

	<cffunction name="getInActive" output="false" returntype="query">

		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Program_Lump_Sum_Name
			WHERE 	Deleted = 0
			AND		Active = 0
			ORDER BY Program_Lump_Sum_Name
		</cfquery>

		<cfreturn qGetActiveComps />

   	</cffunction>

	<cffunction name="add" output="false" hint="Function used to add a new component.">

		<cfargument name="componentName" required="false" default="" />
		<cfargument name="externalID" required="false" default="" />
		<cfargument name="operatingGroupId" required="false" default="0" />
		<cfargument name="allowanceCodeId" required="false" default="0" />
		<cfargument name="samplerelated" required="false" default="0" />
		<cfargument name="selectedTemplateIdList" required="false" default="" />
		<cfargument name="User_ID" required="false" default="" />
		<cfargument name="GLList" required="false" default="" />
		<cfargument name="Deduction_Account" required="false" default="" />
		<cfargument name="Payment_Account" required="false" default="" />
		<cfargument name="Exclude_From_TPA" required="false" default="0" />
		<cfargument name="Lump_Sum_Type" required="false" default="0" />
		<cfargument name="Allow_Negative" required="false" default="0" />
		<cfargument name="Related_to_Equipment" required="false" default="0" />
		<cfargument name="Equipment_value" required="false" default="0" />
		<cfargument name="Accrual_On" required="false" default="0" />
		<cfargument name="Allow_Broker_Payee" required="false" default="0" />
		<cfargument name="TemplatePaidToDefaultCFPages" required="false" default="" type="string"  />
		<cfargument name="TemplatePaidToDefaultRatesGrid" required="false" default="" type="string"  />
		<cfargument name="structTemplatePaidTo" required="false" default="structNew()" type="struct"  />

		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<cfargument name="DisplayID" required="false" default="0" />
		<cfargument name="DisplayDeductionAccount" required="false" default="0" />
		<cfargument name="DisplayPaymentAccount" required="false" default="0" />		
		<!--- D58135 ::  Additional Component info displaye inside program END --->
		<cfargument name="Accrual_Posting_Options" required="false" default="0" />	<!--- 62609 --->
		<cfargument name="ProgramLockTypeID" required="false" default="0" />

		<cfargument name="TPO_Field" required="false" default="0" /> <!--- 95126 --->
		<cfargument name="TPO_Rate_Type" required="false" default="0" /> <!---95126 --->
		<cfargument name="Planner_Target_Type" required="false" default="0" /> <!---98880 --->
		<cfargument name="Manual_LS_Allocation" required="false" default="0" /> <!--- 96456 --->
		
		<cfset bCompNameExists = 0 />
		<cfset bProceedWithInsert = 1 />

		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT	Program_Lump_Sum_Name_ID, External_ID
			FROM	Program_Lump_Sum_Name
			WHERE	Program_Lump_Sum_Name = '#trim(arguments.componentName)#'
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
				INSERT INTO	Program_Lump_Sum_Name
					(
					Program_Lump_Sum_Name,
					External_ID,
					Samples_Related,
					Operating_Group_ID,
					Allowance_Code_ID,
					Deduction_Account,
					Payment_Account,
					Last_Edited_By,
					Last_Edited_Date,
					Exclude_From_TPA,
					Lump_Sum_Type,
					Allow_Negative,
					Related_to_Equipment,
					Equipment_Value,
					Accrual_On,
					Allow_Broker_Payee
					<!--- D58135 ::  Additional Component info displaye inside program START--->					
					,ID_on_ViewProgramPage
					,DeductionAccount_on_ViewProgramPage
					,PaymentAccount_on_ViewProgramPage	
					<!--- D58135 ::  Additional Component info displaye inside program END--->			
					,Accrual_Posting_Options	<!--- 62609 --->
					,Program_Lock_Type_ID
					,TPO_Field <!---95126 --->
					,TPO_Rate_Type <!---95126 --->
					,Planner_Target_Type <!--- 98880 --->
					,Manual_LS_Allocation <!--- 96456 --->
					 )
				VALUES
					(
						<cfqueryparam value="#arguments.componentName#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.externalID#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.samplerelated#" cfsqltype="cf_sql_bit">,
						<cfqueryparam value="#arguments.operatingGroupId#" cfsqltype="cf_sql_integer" null="#arguments.operatingGroupId EQ 0#">,
						<cfqueryparam value="#arguments.allowanceCodeId#" cfsqltype="cf_sql_integer" null="#arguments.allowanceCodeId EQ 0#">,
						<cfqueryparam value="#arguments.Deduction_Account#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.Payment_Account#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_varchar">,
						getdate(),
						<cfqueryparam value="#arguments.Exclude_From_TPA#" cfsqltype="cf_sql_bit">,
						<cfqueryparam value="#arguments.Lump_Sum_Type#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#arguments.Allow_Negative#" cfsqltype="cf_sql_bit">,
						<cfqueryparam value="#arguments.Related_to_Equipment#" cfsqltype="cf_sql_bit">,<!--- D37295 Kraft Equipment LS set up --->
						<cfqueryparam value="#arguments.Equipment_Value#" cfsqltype="cf_sql_varchar">,<!--- D37295 Kraft Equipment LS set up --->
						<cfqueryparam value="#arguments.Accrual_On#" cfsqltype="cf_sql_bit">,
						<cfqueryparam value="#arguments.Allow_Broker_Payee#" cfsqltype="cf_sql_bit">
					<!--- D58135 ::  Additional Component info displaye inside program START--->
					,<cfqueryparam value="#arguments.DisplayID#" cfsqltype="cf_sql_bit">
					,<cfqueryparam value="#arguments.DisplayDeductionAccount#" cfsqltype="cf_sql_bit">
					,<cfqueryparam value="#arguments.DisplayPaymentAccount#" cfsqltype="cf_sql_bit">
					<!--- D58135 ::  Additional Component info displaye inside program END--->		
					,<cfqueryparam value="#arguments.Accrual_Posting_Options#" cfsqltype="cf_sql_integer">	<!--- 62609 --->
					,<cfqueryparam value="#arguments.ProgramLockTypeID#" cfsqltype="CF_SQL_INTEGER">
					,<cfqueryparam value="#arguments.TPO_Field#" cfsqltype="CF_SQL_INTEGER"> <!--- 95126 --->
					,<cfqueryparam value="#arguments.TPO_Rate_Type#" cfsqltype="CF_SQL_INTEGER"> <!--- 95126 --->					
					,<cfqueryparam value="#arguments.Planner_Target_Type#" cfsqltype="CF_SQL_INTEGER"> <!--- 98880 --->
					,<cfqueryparam value="#arguments.Manual_LS_Allocation#" cfsqltype="cf_sql_bit"> <!--- 96456 --->
					)
				SELECT Program_Lump_Sum_Name_ID = @@IDENTITY
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
					'#qGetActiveComps.Program_Lump_Sum_Name_ID#',
					3
				)
				</cfquery>
				</cfloop>
			</Cfif>

			<cfset templateManager.saveDiscountComponentTemplates(qGetActiveComps.Program_Lump_Sum_Name_ID, 3, arguments.selectedTemplateIdList,
				arguments.TemplatePaidToDefaultCFPages, arguments.TemplatePaidToDefaultRatesGrid, arguments.structTemplatePaidTo) />
		</cfif>

		<cfreturn bCompNameExists />

   	</cffunction>

	<cffunction name="deactivate" output="false" hint="Function used to deactivate components.">

		<cfargument name="compIds" required="false" default="" />

		<cfquery datasource="#application.datasource#">
			UPDATE 	Program_Lump_Sum_Name
			SET		Active = 0
			WHERE	Program_Lump_Sum_Name_ID IN(#arguments.compIds#)
		</cfquery>

   	</cffunction>

	<cffunction name="activate" output="false" hint="Function used to activate components.">

		<cfargument name="compIds" required="false" default="" />

		<cfquery datasource="#application.datasource#">
			UPDATE 	Program_Lump_Sum_Name
			SET		Active = 1
			WHERE	Program_Lump_Sum_Name_ID IN(#arguments.compIds#)
		</cfquery>

   	</cffunction>

	<cffunction name="delete" output="false" hint="Function used to delete components.">

		<cfargument name="compIds" required="false" default="" />

		<cfquery datasource="#application.datasource#">
			UPDATE 	Program_Lump_Sum_Name
			SET		Deleted = 1
			WHERE	Program_Lump_Sum_Name_ID IN(#arguments.compIds#)
		</cfquery>

   	</cffunction>

	<cffunction name="update" output="false" hint="Function used to update components." returntype="numeric">

		<cfargument name="compId" required="false" default="" />
		<cfargument name="compName" required="false" default="" />
		<cfargument name="externalID" required="false" default="" />
   		<cfargument name="operatingGroupId" required="false" default="0" />
		<cfargument name="allowanceCodeId" required="false" default="0" />
		<cfargument name="samplerelated" required="false" default="0" />
		<cfargument name="selectedTemplateIdList" required="false" default="" />
		<cfargument name="User_ID" required="false" default="">
		<cfargument name="GLList" required="false" default="" />
		<cfargument name="Deduction_Account" required="false" default="" />
		<cfargument name="Payment_Account" required="false" default="" />
		<cfargument name="Exclude_From_TPA" required="false" default="0" />
		<cfargument name="Lump_Sum_Type" required="false" default="0" />
		<cfargument name="Allow_Negative" required="false" default="0" />
		<cfargument name="Related_to_Equipment" required="false" default="0" /><!--- D37295 Kraft Equipment LS set up --->
		<cfargument name="Equipment_value" required="false" default="0" /><!--- D37295 Kraft Equipment LS set up --->
		<cfargument name="Accrual_On" required="false" default="0" />
		<cfargument name="Allow_Broker_Payee" required="false" default="0" />
		<cfargument name="TemplatePaidToDefaultCFPages" required="false" default="" type="string"  />
		<cfargument name="TemplatePaidToDefaultRatesGrid" required="false" default="" type="string"  />
		<cfargument name="structTemplatePaidTo" required="false" default="structNew()" type="struct"  />

		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<cfargument name="DisplayID" required="false" default="0" />
		<cfargument name="DisplayDeductionAccount" required="false" default="0" />
		<cfargument name="DisplayPaymentAccount" required="false" default="0" />		
		<!--- D58135 ::  Additional Component info displaye inside program END --->
		<!--- 62609 Lump Sum Component Settings - Accrual Dropdown  START--->	
		<cfargument name="Accrual_Posting_Options" required="false" default="0" />	
		<cfargument name="ProgramLockTypeID" required="false" default="0" />

		<cfargument name="TPO_Field" required="false" default="0" /> <!--- 95126 --->
		<cfargument name="TPO_Rate_Type" required="false" default="0" /> <!---95126 --->
		<cfargument name="Planner_Target_Type" required="true" /> <!--- 98880 --->
		<cfargument name="Manual_LS_Allocation" required="false" default="0" /> <!--- 96456 --->

			
		<cfif Accrual_On EQ 0>
			<cfset arguments.Accrual_Posting_Options = 0>
		</cfif>
		<!--- 62609 Lump Sum Component Settings - Accrual Dropdown  END--->	
		<cfset bCompNameExists = 0 />
		<cfset bProceedWithUpdate = 1 />
			
		<!---check to see if the name already exists--->
		<cfquery name="qCheckCompNames" datasource="#application.datasource#">
			SELECT	*
			FROM	Program_Lump_Sum_Name
			WHERE	Program_Lump_Sum_Name = '#trim(arguments.compName)#'
			AND		Program_Lump_Sum_Name_ID != #arguments.compId#
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
				<cfset useLakebaseForqCheckIfCurrentcomponent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetalltemplatediscountcomponents")>
<cfif useLakebaseForqCheckIfCurrentcomponent>
	<cftry>
		<cfset qCheckIfCurrentcomponent = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetalltemplatediscountcomponents", {
				"allowance_code_id" = "eq.#arguments.allowanceCodeId#",
				"component_id" = "eq.#arguments.compId#",
				"select" = "component_id"
			}), "component_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckIfCurrentcomponent = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckIfCurrentcomponent>
<cfquery name="qCheckIfCurrentcomponent" dbtype="query">
					SELECT	Component_ID
					FROM	qGetAllTemplateDiscountComponents
					WHERE	Allowance_Code_ID = #arguments.allowanceCodeId#
					AND		Component_ID = #arguments.compId#
				</cfquery>
</cfif>
				<cfif not qCheckIfCurrentcomponent.recordCount>
					<cfset bProceedWithUpdate = 0 />
					<cfset bCompNameExists = 3 />
				</cfif>
			</cfif>
		</cfif>

		<cfif bProceedWithUpdate>
			<cfquery datasource="#application.datasource#">
				UPDATE 	Program_Lump_Sum_Name
				SET		Program_Lump_Sum_Name = <cfqueryparam value="#arguments.compName#" cfsqltype="cf_sql_varchar">,
						External_ID = <cfqueryparam value="#arguments.externalID#" cfsqltype="cf_sql_varchar">,
						Samples_Related = <cfqueryparam value="#arguments.samplerelated#" cfsqltype="cf_sql_bit">,
						Operating_Group_ID = <cfqueryparam value="#arguments.operatingGroupId#" cfsqltype="cf_sql_integer" null="#arguments.operatingGroupId EQ 0#">,
						Allowance_Code_ID = <cfqueryparam value="#arguments.allowanceCodeId#" cfsqltype="cf_sql_integer" null="#arguments.allowanceCodeId EQ 0#">,
						Deduction_Account = <cfqueryparam value="#arguments.Deduction_Account#" cfsqltype="cf_sql_varchar">,
						Payment_Account = <cfqueryparam value="#arguments.Payment_Account#" cfsqltype="cf_sql_varchar">,
						Last_Edited_By = <cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_varchar">,
						Exclude_From_TPA = <cfqueryparam value="#arguments.Exclude_From_TPA#" cfsqltype="cf_sql_bit">,
						Lump_Sum_Type = <cfqueryparam value="#arguments.Lump_Sum_Type#" cfsqltype="cf_sql_integer">,
						Allow_Negative = <cfqueryparam value="#arguments.Allow_Negative#" cfsqltype="cf_sql_bit">,
						Related_to_Equipment = <cfqueryparam value="#val(arguments.Related_to_Equipment)#" cfsqltype="cf_sql_bit">, <!--- D37295 Kraft Equipment LS set up --->
						Equipment_Value = <cfqueryparam value="#val(arguments.Equipment_Value)#" cfsqltype="cf_sql_integer">,<!--- D37295 Kraft Equipment LS set up --->
						Accrual_On = <cfqueryparam value="#val(arguments.Accrual_On)#" cfsqltype="cf_sql_bit">,<!--- D42830 :: EVENT ERROR:  Invalid data ' for CFSQLTYPE CF_SQL_BIT --->
						Allow_Broker_Payee = <cfqueryparam value="#arguments.Allow_Broker_Payee#" cfsqltype="cf_sql_bit">,
						Last_Edited_Date = getdate()
						<!--- D58135 ::  Additional Component info displaye inside program START--->
						,ID_on_ViewProgramPage = <cfqueryparam value="#arguments.DisplayID#" cfsqltype="cf_sql_bit">
						,DeductionAccount_on_ViewProgramPage = <cfqueryparam value="#arguments.DisplayDeductionAccount#" cfsqltype="cf_sql_bit">
						,PaymentAccount_on_ViewProgramPage	= <cfqueryparam value="#arguments.DisplayPaymentAccount#" cfsqltype="cf_sql_bit">
						<!--- D58135 ::  Additional Component info displaye inside program END--->						
						,Accrual_Posting_Options = <cfqueryparam value="#arguments.Accrual_Posting_Options#" cfsqltype="cf_sql_integer"><!--- 62609 --->
						,Program_Lock_Type_ID = <cfqueryparam value="#arguments.ProgramLockTypeID#" cfsqltype="CF_SQL_INTEGER">
						,TPO_Field = <cfqueryparam value="#arguments.TPO_Field#" cfsqltype="CF_SQL_INTEGER"> <!--- 95126--->
						,TPO_Rate_Type = <cfqueryparam value="#arguments.TPO_Rate_Type#" cfsqltype="CF_SQL_INTEGER"> <!--- 95126--->
						,Planner_Target_Type = <cfqueryparam value="#arguments.Planner_Target_Type#" cfsqltype="CF_SQL_INTEGER">
						,Manual_LS_Allocation = <cfqueryparam value="#arguments.Manual_LS_Allocation#" cfsqltype="cf_sql_bit"> <!--- 96456 --->
				WHERE	Program_Lump_Sum_Name_ID = #arguments.compId#
			</cfquery>

			<cfif len(trim(arguments.GLList)) GT 0>
				<cfloop list="#arguments.GLList#" index="GL_Account_ID">
					<cfquery name="DeletefromMapping" datasource="#application.datasource#">
					DELETE FROM GL_Component_Mapping
					WHERE GL_Account_ID = '#GL_Account_ID#'
					AND Component_Name_ID = '#arguments.compId#'
					AND Discount_Type_ID = 3
					</cfquery>
				</cfloop>
			</cfif>

			<cfset templateManager.saveDiscountComponentTemplates(arguments.compId, 3, arguments.selectedTemplateIdList,
				arguments.TemplatePaidToDefaultCFPages, arguments.TemplatePaidToDefaultRatesGrid, arguments.structTemplatePaidTo) />
		</cfif>

		<cfreturn bCompNameExists />

   	</cffunction>

	<cffunction name="canDelete" output="false" returntype="boolean" hint="Function used to verify if a component can be deleted or not.">

   		<cfargument name="nameID" type="numeric" required="false" default="" />

		<cfquery name="qCheckCompName" datasource="#application.datasource#">
			SELECT 	count(*) as count
			FROM 	Program_Lump_Sums
			WHERE 	Program_Lump_Sum_Name_ID = <cfqueryparam value="#arguments.nameID#" cfsqltype="CF_SQL_INTEGER" />
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

</cfcomponent>
