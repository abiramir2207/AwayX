<cfcomponent>

   <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
   <cfset appSettings = genSettingsManager.get()>
   <cffunction name="set" output="false" returntype="struct">

	  	<cfargument name="compID" type="string" required="true" default="">
		<cfargument name="compNameId" type="string" required="true" default="">
		<cfargument name="programID" type="numeric" required="true" default=0>
		<cfargument name="compUUID" type="string" required="true" default="#CreateUUID()#">
		<cfargument name="componentPaidTo" type="numeric" required="true" default=1>
		<cfargument name="GL_Account_ID"  required="false" default=0>
		<cfargument name="Vendor_Master_ID"  required="false" default=0>
		<cfargument name="PaymentCycle"  required="false" default=0>
		<cfargument name="Claim_Mechanics" type="numeric" required="true" default=1>
		<cfargument name="BasisCode" type="numeric" required="true" default=0>
		<cfargument name="TreatmentCode" type="numeric" required="true" default=0>
		<cfargument name="VendorSelection"  required="false" default=0>
		<cfargument name="ParentProgramRebatesComponentID"  required="false" default=0>
		<cfargument name="Payee_Selection"  required="false" default=0>
		<cfargument name="Alternate_Recapture_Rate" required="false" default="0"><!--- D38536  :: Alternate recapture rates per component --->

		<!--- 62343 8.0 - Blended Rate, CF START --->
		<cfargument name="from_date" type="string" required="true" default="">
		<cfargument name="to_date" type="string" required="true" default="">
		<cfargument name="Blended_Rate_On" type="numeric" required="true" default="0">
		<!--- 62343 8.0 - Blended Rate, CF END --->
		<!---65711 --->
		<cfargument name="compDefaultRate" type="string" required="true" default=0>
		<cfargument name="compDefaultUOM" type="numeric" required="true" default=0>
		<cfargument name="IsSecondComponent" required="false" default="0" />
		<cfargument name="DontCountVolume" required="false" default="0" />

		<!---65711 --->
		<!---get and set the rebate rules for this component--->
		<cfset qGetComp = this.getComp(arguments.compNameId) />

   		<cfscript>
			tmpStruct = structNew();
			tmpStruct.compID = arguments.compID;
			tmpStruct.compNameId = arguments.compNameId;
			tmpStruct.programID = arguments.programID;
			tmpStruct.compUUID = arguments.compUUID;
			tmpStruct.componentPaidTo = arguments.componentPaidTo;
			tmpStruct.Vendor_Master_ID = arguments.Vendor_Master_ID;
			tmpStruct.PaymentCycle = arguments.PaymentCycle;
			tmpStruct.GL_Account_ID = arguments.GL_Account_ID;
			tmpStruct.Claim_Mechanics = arguments.Claim_Mechanics;
			tmpStruct.BasisCode = arguments.BasisCode;
			tmpStruct.TreatmentCode = arguments.TreatmentCode;
			tmpStruct.VendorSelection = arguments.VendorSelection;
			tmpStruct.ParentProgramRebatesComponentID = arguments.ParentProgramRebatesComponentID;
			tmpStruct.Payee_Selection = arguments.Payee_Selection;
			tmpStruct.Alternate_Recapture_Rate = arguments.Alternate_Recapture_Rate;// D38536  :: Alternate recapture rates per component
			tmpStruct.compName = qGetComp.Program_Rebates_Component_Name;
			tmpStruct.hasRules = qGetComp.Has_Rules;
			tmpStruct.rebate_type = qGetComp.rebate_type;
			tmpStruct.rulesRequired = qGetComp.Rule_Required;
			tmpStruct.EffectiveMarginFlag = 0;
			if(isNumeric(qGetComp.Required_Effective_Rate_Percent))
			{
				tmpStruct.EffectiveMarginFlag = qGetComp.Required_Effective_Rate_Percent;
			}
			tmpStruct.Blended_Rate_from_date = arguments.from_date; //62343
			tmpStruct.Blended_Rate_to_date = arguments.to_date;//62343
			tmpStruct.Blended_Rate_On = arguments.Blended_Rate_On;//62343
			tmpStruct.compRate = arguments.compDefaultRate;//65711
			tmpStruct.compUOM = arguments.compDefaultUOM;//65711
			tmpStruct.IsSecondComponent = arguments.IsSecondComponent;
			tmpStruct.DontCountVolume = arguments.DontCountVolume; //79614
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
		<cfargument name="lAllowList" type="string" required="false" default="0" />
		<cfargument name="isUSDA" required="false" default="0" />
		<cfargument name="Price_Protection_on" type="string" required="false" default="0" />
		<cfargument name="get_all_active" type="string" required="false" default="0" />
		<cfargument name="arAllowList" type="array" required="false" default="#ArrayNew(1)#" />
		<cfargument name="EzButton_Disable" type="boolean" required="false" default="0" />
		<cfargument name="GetEZButtonComp" required="false" default="" />
		<cfargument name="ExcludeSecondComponent" required="false" default="0" />
		<cfargument name="ProgramID" required="false" default="0" />


		<cfparam name="lRestrictList" default="" />

		<!---get a list of rebate comps to filter on based if a profile is was passed--->
		<cfif trim(arguments.profileId) neq "">

			<cfset lRestrictList = CreateObject("component","components.programs.rebates.RebateComponentProfile").compIdsToFilter(arguments.profileId) />

		</cfif>

		<cfquery name="dropTempTable" datasource="#application.datasource#">
		IF OBJECT_ID('tempdb..##tmp_Rebate_Comp_List') IS NOT NULL
		DROP TABLE ##tmp_Rebate_Comp_List
		</cfquery>

		<cfset arAllowListLen = ArrayLen(arAllowList) />
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT 	DISTINCT Program_Rebates_Component_Name.*,
					Allowance_Code.Allowance_Code_Number, Allowance_Code.Allowance_Code_Desc,
					(SELECT TOP 1 GL_Component_Mapping.GL_Account_ID
					FROM GL_Component_Mapping
					WHERE GL_Component_Mapping.Component_Name_ID = Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
					AND GL_Component_Mapping.Discount_Type_ID = 2
					AND GL_Account_ID IS NOT NULL
					) As GL_Account_ID
			INTO ##tmp_Rebate_Comp_List
			FROM 	Program_Rebates_Component_Name

			LEFT JOIN Allowance_Code
			ON		Allowance_Code.Allowance_Code_ID = Program_Rebates_Component_Name.Allowance_Code_ID

			/* Get the GL_Code_Account_ID for the component to check whether validation for
			 required GL_Code_Account_ID is required or not
			*/
			LEFT JOIN GL_Component_Mapping
			ON GL_Component_Mapping.Component_Name_ID = Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
			AND GL_Component_Mapping.Discount_Type_ID = 2

			WHERE 	Program_Rebates_Component_Name.Deleted = 0
			AND		Program_Rebates_Component_Name.Active = 1
			<cfif appSettings.get_Setting('Forbid_Same_Component_Same_Pays_To_In_Program') EQ '1'>
				AND Program_Rebates_Component_Name_ID NOT IN (SELECT Program_Rebates_Component_Name_ID FROM Program_Rebates_Component
				WHERE program_ID  = '#arguments.ProgramID#' AND Deleted = 0)
			</cfif>
			<cfif trim(lRestrictList) neq "">
			AND		Program_Rebates_Component_Name_ID NOT IN (#lRestrictList#)
			</cfif>
			<cfif trim(arguments.lAllowList) neq "0">
			<cfif trim(arguments.lAllowList) neq ""><!------ If list is not empty ----->
			AND		Program_Rebates_Component_Name_ID IN (#arguments.lAllowList#)
			<cfelse><!------ If list is empty, don't return anything ----->
			AND		1=2
			</cfif>
			</cfif>
			<cfloop from="1" to="#arAllowListLen#" index="i">
			<cfset lAllowList = arAllowList[i] />
			<cfif trim(lAllowList) neq "0">
			<cfif trim(lAllowList) neq ""><!------ If list is not empty ----->
			AND		Program_Rebates_Component_Name_ID IN (#lAllowList#)
			<cfelse><!------ If list is empty, don't return anything ----->
			AND		1=2
			</cfif>
			</cfif>
			</cfloop>
			<cfif get_all_active EQ 0>
				AND Program_Rebates_Component_Name.Rebate_type NOT IN (2)
			</cfif>
			<!---If it's a USDA type program, only return USDA components--->
			<cfif arguments.isUSDA IS 1>
			AND		Is_USDA_NOI_Comp = 1
			</cfif>
			<cfif arguments.EzButton_Disable EQ 1>
			<cfif len(arguments.GetEZButtonComp) EQ 0>
			and 1 = 2
			<cfelse>
			and Program_Rebates_Component_Name_ID IN (#arguments.GetEZButtonComp#)
			</cfif>
			</cfif>

			SELECT * FROM ##tmp_Rebate_Comp_List
			<cfif arguments.ExcludeSecondComponent eq 1>
			<!--- Dev Note(79237) - Exclude the 2nd (Child) component, if it is already a 2nd component of any component on the program. --->
			WHERE Program_Rebates_Component_Name_ID NOT IN
			(
				SELECT DISTINCT Second_Component_Name_ID
				FROM ##tmp_Rebate_Comp_List
			)
			</cfif>
			ORDER BY Program_Rebates_Component_Name
		</cfquery>

		<cfreturn qGetActiveComps />

   	</cffunction>

	<cffunction name="getComp" output="false" returntype="query">

   		<cfargument name="compId" required="false" default=0 />

		<cfquery name="qGetComp" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Program_Rebates_Component_Name
			WHERE 	Program_Rebates_Component_Name_ID = #arguments.compId#
		</cfquery>

		<cfreturn qGetComp />

   	</cffunction>

	<cffunction name="getCompPayTo" output="false" returntype="query">

   		<cfargument name="payToId" required="false" default=0 />

		<cfquery name="qGetCompPayTo" datasource="#application.datasource#">
			SELECT 	Payment_Paid_To_Type_name
			FROM 	Payment_Paid_To_Types
			WHERE 	Payment_Paid_To_ID = #arguments.payToId#
		</cfquery>

		<cfreturn qGetCompPayTo />

   	</cffunction>

	<cffunction name="getInActive" output="false" returntype="query">

		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT 	Program_Rebates_Component_Name,
					Program_Rebates_Component_Name_ID,
					External_ID,
					Operating_Group_ID
			FROM 	Program_Rebates_Component_Name
			WHERE 	Deleted = 0
			AND		Active = 0
			ORDER BY Program_Rebates_Component_Name
		</cfquery>

		<cfreturn qGetActiveComps />

   	</cffunction>

	<cffunction name="add" output="false" hint="Function used to add a new component.">

		<cfargument name="componentName" required="false" default="" />
		<cfargument name="externalID" required="false" default="" />
		<cfargument name="Rebate_Percent_Option_ID" type="numeric" required="false" default="1" />
		<cfargument name="operatingGroupId" required="false" default="0" />
		<cfargument name="Rebate_type" required="false" default="0" />
		<cfargument name="allowanceCodeId" required="false" default="0" />
		<cfargument name="requiredEffectiveRatePercent" required="false" default="0" />
		<cfargument name="selectedTemplateIdList" required="false" default="" />
		<cfargument name="Accrual_On" required="false" default="0" />
		<cfargument name="Exclude_Brokerage" required="false" default="0" />
		<cfargument name="Off_Invoice_On" required="false" default="0" />
		<cfargument name="User_ID" required="false" default="" />
		<cfargument name="GLList" required="false" default="" />
		<cfargument name="Rebate_Margin_Percent_Option_ID" type="numeric" required="false" default="1" />
		<cfargument name="Interface_as_Rate" required="false" default="1" />
		<cfargument name="Deduction_Account" required="false" default="" />
		<cfargument name="Payment_Account" required="false" default="" />
		<cfargument name="Auto_Pay_Net_Of_Cash_Discount" type="boolean" required="false" default="0" />
		<cfargument name="Auto_Pay_Net_Of_Freight_Allowance" type="boolean" required="false" default="0" />
		<cfargument name="Auto_Pay_Exclude_Credit_Type" type="boolean" required="false" default="0" />
		<cfargument name="Credit_Type_Select" type="string" required="false" default="" />
		<cfargument name="FOB_PayeeType1_DiscountType" type="string" required="false" default="" />
		<cfargument name="FOB_PayeeType2_DiscountType" type="string" required="false" default="" />
		<cfargument name="FOB_PayeeType3_DiscountType" type="string" required="false" default="" />
		<cfargument name="Recapture_Rate_From_Program_Budget" required="false" default="0" />
		<!--- D38536  :: Alternate recapture rates per component START--->
		<cfargument name="Alternate_Recapture_Rate" required="false" default="0" />
		<cfargument name="rate1" required="false" default="0" />
		<cfargument name="rate2" required="false" default="0" />
		<cfargument name="rate3" required="false" default="0" />
		<cfargument name="description1" required="false" default="0" />
		<cfargument name="description2" required="false" default="0" />
		<cfargument name="description3" required="false" default="0" />
		<cfargument name="AlternateRateTemplateList1" required="false" default="0" />
		<cfargument name="AlternateRateTemplateList2" required="false" default="0" />
		<cfargument name="AlternateRateTemplateList3" required="false" default="0" />
		<!--- D38536  :: Alternate recapture rates per component END--->
		<!---D40991 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work START--->
		<cfargument name="Update_BB_Expected_Rate" required="false" default="0" />
		<cfargument name="Expected_Rate" required="false" default="0" />
		<cfargument name="Program_Pays_To" required="false" default="0" />
		<cfargument name="Exclude_From_Recapture" required="false" default="0" />
		<!---D40991 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work END --->
		<!--- 43819 Recapture - operator exclusion list --->
		<cfargument name="Alternate_Recapture_By_Operator" required="false" default="0" />
		<!---D50514 :: Sysco - CF changes needed for enhancement in 45814.  CF Work START--->
		<cfargument name="Is_Retail" required="false" default="0">
		<cfargument name="Net_Out_of_Fixed_Price" required="false" default="0">
		<!---D50514 :: Sysco - CF changes needed for enhancement in 45814.  CF Work END--->
		<cfargument name="TemplatePaidToDefaultCFPages" required="false" default="" type="string"  />
		<cfargument name="TemplatePaidToDefaultRatesGrid" required="false" default="" type="string"  />
		<cfargument name="structTemplatePaidTo" required="false" default="structNew()" type="struct"  />

		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<cfargument name="DisplayID" required="false" default="0" />
		<cfargument name="DisplayDeductionAccount" required="false" default="0" />
		<cfargument name="DisplayPaymentAccount" required="false" default="0" />
		<!--- D58135 ::  Additional Component info displaye inside program END --->
		<cfargument name="ProgramLockTypeID" required="false" default="0" />

		<!---D79237 Rebate - OI and Redi START--->
		<cfargument name="Include_Second_Component" required="false" default="0" />
		<cfargument name="Second_Component_Name_ID" required="false" default="0" />
		<cfargument name="Second_Component_Payment_Type_ID" required="false" default="0" />
		<cfargument name="Second_Component_GL_Account_ID" required="false" default="0" />
		<cfargument name="Second_Component_Payment_Cycle_ID" required="false" default="0" />
		<!--- 95126 START --->
		<cfargument name="TPO_Field" required="false" default="0" />
		<cfargument name="TPO_Rate_Type" required="false" default="0" />
		<!--- 95126 END --->

		<cfargument name="Expected_Rate_Affect_Discount_Type" required="false" default="0" /> <!--- 91550 --->
		<cfargument name="Expected_Rate_Apply_All_Templates" required="false" default="0" /> <!---91550 --->
		<cfargument name="ExpectedRateTemplateList" required="false" default="0" /> <!---91550 --->

		<cfif arguments.Include_Second_Component EQ 0>
			<cfset arguments.Second_Component_Name_ID = 0>
			<cfset arguments.Second_Component_Payment_Type_ID = 0>
			<cfset arguments.Second_Component_GL_Account_ID = 0>
			<cfset arguments.Second_Component_Payment_Cycle_ID = 0>
		</cfif>
		<!---D79237 Rebate - OI and Redi END--->

		<cfset bCompNameExists = 0 />
		<cfset bProceedWithInsert = 1 />

		<!------ Check if another component with same name exist ----->
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT	Program_Rebates_Component_Name_ID,
					External_ID
			FROM	Program_Rebates_Component_Name
			WHERE	0=0
			AND Program_Rebates_Component_Name = '#trim(arguments.componentName)#'
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

		<cfif bProceedWithInsert EQ 1>

			<cfif arguments.Rebate_Percent_Option_ID neq 1> <!--- 1=net sales, 2=gross sales --->
				<cfset arguments.Auto_Pay_Net_Of_Cash_Discount = 0 />
				<cfset arguments.Auto_Pay_Net_Of_Freight_Allowance = 0 />
				<cfset arguments.Auto_Pay_Exclude_Credit_Type = 0 />
			</cfif>
			<cfif arguments.Auto_Pay_Exclude_Credit_Type eq 0>
				<cfset arguments.Credit_Type_Select = "" />
			</cfif>

			<cfquery name="qGetActiveComps" datasource="#application.datasource#">
				SET NOCOUNT ON
				INSERT INTO	Program_Rebates_Component_Name
					(Program_Rebates_Component_Name,
					External_ID,
					Rebate_Percent_Option_ID,
					Rebate_Margin_Percent_Option_ID,
					Operating_Group_ID,
					Rebate_type,
					Allowance_Code_ID,
					Required_Effective_Rate_Percent,
					Accrual_On,
					Exclude_Brokerage,
					Off_Invoice_On,
					Deduction_Account,
					Payment_Account,
					Interface_As_Rate,
					Auto_Pay_Net_Of_Cash_Discount,
					Auto_Pay_Net_Of_Freight_Allowance,
					Auto_Pay_Exclude_Credit_Type,
					Last_Edited_By,
					Last_Edited_Date
					,Recapture_Rate_From_Program_Budget
					,Alternate_Recapture_Rate<!--- D38536  :: Alternate recapture rates per component --->
					<!--- D40991 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work --->
					,Update_BB_Expected_Rate
					,Expected_Rate
					,Program_Pays_To
					,Exclude_From_Recapture
					<!--- D40991 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work --->
					,Alternate_Recapture_By_Operator
					,Is_Retail
					,Net_Out_of_Fixed_Price
					<!--- D58135 ::  Additional Component info displaye inside program START--->
					,ID_on_ViewProgramPage
					,DeductionAccount_on_ViewProgramPage
					,PaymentAccount_on_ViewProgramPage
					<!--- D58135 ::  Additional Component info displaye inside program END--->
					,Program_Lock_Type_ID
					,Include_Second_Component<!---D79237 --->
					,Second_Component_Name_ID<!---D79237 --->
					,Second_Component_Payment_Type_ID<!---D79237 --->
					,Second_Component_GL_Account_ID
					,Second_Component_Payment_Cycle_ID
					,TPO_Field <!---95126 --->
					,TPO_Rate_Type <!---95126 --->
					,Expected_Rate_Affect_Discount_Type<!--- 91550--->
					,Expected_Rate_Apply_All_Templates<!--- 91550--->
					 )

				VALUES
					('#arguments.componentName#',
					'#arguments.externalID#',
					#arguments.Rebate_Percent_Option_ID#,
					<cfqueryparam value="#arguments.Rebate_Margin_Percent_Option_ID#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.operatingGroupId#" cfsqltype="CF_SQL_INTEGER" null="#arguments.operatingGroupId EQ 0#">,
					<cfqueryparam value="#arguments.Rebate_type#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.allowanceCodeId#" cfsqltype="CF_SQL_INTEGER" null="#arguments.allowanceCodeId EQ 0#">,
					<cfqueryparam value="#arguments.requiredEffectiveRatePercent#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.Accrual_On#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.Exclude_Brokerage#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.Off_Invoice_On#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.Deduction_Account#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.Payment_Account#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.Interface_As_Rate#" cfsqltype="CF_SQL_BIT">,
					<cfqueryparam value="#arguments.Auto_Pay_Net_Of_Cash_Discount#" cfsqltype="cf_sql_bit">,
					<cfqueryparam value="#arguments.Auto_Pay_Net_Of_Freight_Allowance#" cfsqltype="cf_sql_bit">,
					<cfqueryparam value="#arguments.Auto_Pay_Exclude_Credit_Type#" cfsqltype="cf_sql_bit">,
					<cfqueryparam value="#arguments.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
					getdate()
					,<cfqueryparam value="#arguments.Recapture_Rate_From_Program_Budget#" cfsqltype="cf_sql_bit">
					,<cfqueryparam value="#arguments.Alternate_Recapture_Rate#" cfsqltype="cf_sql_bit">		<!--- D38536  :: Alternate recapture rates per component --->
					<!--- D40991 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work --->
					,<cfqueryparam value="#arguments.Update_BB_Expected_Rate#" cfsqltype="cf_sql_bit">
					,<cfqueryparam value="#arguments.Expected_Rate#" cfsqltype="CF_SQL_INTEGER">
					,<cfqueryparam value="#arguments.Program_Pays_To#" cfsqltype="CF_SQL_INTEGER">
					,<cfqueryparam value="#arguments.Exclude_From_Recapture#" cfsqltype="cf_sql_bit">
					<!--- D40991 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work --->
					,<cfqueryparam value="#arguments.Alternate_Recapture_By_Operator#" cfsqltype="cf_sql_bit">
					,<cfqueryparam value="#arguments.Is_Retail#" cfsqltype="CF_SQL_INTEGER">
					,<cfqueryparam value="#arguments.Net_Out_of_Fixed_Price#" cfsqltype="CF_SQL_INTEGER">
					<!--- D58135 ::  Additional Component info displaye inside program START--->
					,<cfqueryparam value="#arguments.DisplayID#" cfsqltype="cf_sql_bit">
					,<cfqueryparam value="#arguments.DisplayDeductionAccount#" cfsqltype="cf_sql_bit">
					,<cfqueryparam value="#arguments.DisplayPaymentAccount#" cfsqltype="cf_sql_bit">
					<!--- D58135 ::  Additional Component info displaye inside program END--->
					,<cfqueryparam value="#arguments.ProgramLockTypeID#" cfsqltype="CF_SQL_INTEGER">
					,<cfqueryparam value="#arguments.Include_Second_Component#" cfsqltype="cf_sql_bit"><!---D79237 --->
					,<cfqueryparam value="#arguments.Second_Component_Name_ID#" cfsqltype="CF_SQL_INTEGER"><!---D79237 --->
					,<cfqueryparam value="#arguments.Second_Component_Payment_Type_ID#" cfsqltype="CF_SQL_INTEGER"><!---D79237 --->
					,<cfqueryparam value="#arguments.Second_Component_GL_Account_ID#" cfsqltype="CF_SQL_INTEGER">
					,<cfqueryparam value="#arguments.Second_Component_Payment_Cycle_ID#" cfsqltype="CF_SQL_INTEGER">
					,<cfqueryparam value="#arguments.TPO_Field#" cfsqltype="CF_SQL_INTEGER"> <!--- 95126 --->
					,<cfqueryparam value="#arguments.TPO_Rate_Type#" cfsqltype="CF_SQL_INTEGER"> <!--- 95126 --->
					,<cfqueryparam value="#arguments.Expected_Rate_Affect_Discount_Type#" cfsqltype="CF_SQL_INTEGER"> <!--- 91550--->
					,<cfqueryparam value="#arguments.Expected_Rate_Apply_All_Templates#" cfsqltype="CF_SQL_INTEGER"> <!--- 91550--->
					)
				SELECT Program_Rebates_Component_Name_ID = @@IDENTITY
				SET NOCOUNT OFF
			</cfquery>

							<!--- D38536  :: Alternate recapture rates per component START--->
							<cfset alternateRate = this.alternateRate(
																	compId= #qGetActiveComps.Program_Rebates_Component_Name_ID#
																	,alternate_recapture_rate=#arguments.alternate_recapture_rate#
																	,rate1=#arguments.rate1#
																	,rate2=#arguments.rate2#
																	,rate3=#arguments.rate3#
																	,description1=#arguments.description1#
																	,description2=#arguments.description2#
																	,description3=#arguments.description3#
																	,AlternateRateTemplateList1=#arguments.AlternateRateTemplateList1#
																	,AlternateRateTemplateList2=#arguments.AlternateRateTemplateList2#
																	,AlternateRateTemplateList3=#arguments.AlternateRateTemplateList3#
																	)/>
						<!--- D38536  :: Alternate recapture rates per component END--->

			<cfset templateManager.saveDiscountComponentTemplates(qGetActiveComps.Program_Rebates_Component_Name_ID, 2, arguments.selectedTemplateIdList,
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
					'#qGetActiveComps.Program_Rebates_Component_Name_ID#',
					2
				)
				</cfquery>
				</cfloop>
			</Cfif>

			<cfset saveCreditTypeExclusion(
					Rebate_Component_Name_ID = qGetActiveComps.Program_Rebates_Component_Name_ID,
					Credit_Type_Select = arguments.Credit_Type_Select
					) />

			<cfset application.oController.getObject(path="mvc.Models.Settings.FOBPriceIndicatorManager",name="FOBPriceIndicatorManager",bReload= 0) />
			<!--- save auto pay fob price indicator list for payee = distributor --->
			<cfset application.oFOBPriceIndicatorManager.saveProgramComponentFOBPriceIndicator(
					payeeTypeId = 1,
					discountTypeId = 2,
					componentNameId = qGetActiveComps.Program_Rebates_Component_Name_ID,
					FOBList = arguments.FOB_PayeeType1_DiscountType) />
			<!--- save auto pay fob price indicator list for payee = operator --->
			<cfset application.oFOBPriceIndicatorManager.saveProgramComponentFOBPriceIndicator(
					payeeTypeId = 2,
					discountTypeId = 2,
					componentNameId = qGetActiveComps.Program_Rebates_Component_Name_ID,
					FOBList = arguments.FOB_PayeeType2_DiscountType) />
			<!--- save auto pay fob price indicator list for payee = broker --->
			<cfset application.oFOBPriceIndicatorManager.saveProgramComponentFOBPriceIndicator(
					payeeTypeId = 3,
					discountTypeId = 2,
					componentNameId = qGetActiveComps.Program_Rebates_Component_Name_ID,
					FOBList = arguments.FOB_PayeeType3_DiscountType) />

					<cfif ! arguments.Expected_Rate_Apply_All_Templates>
						<cfloop list="#arguments.ExpectedRateTemplateList#" index="FirstParentID">
							<cfquery name="DeleteExpectedRateTemplate" datasource="#application.datasource#">
								INSERT INTO Program_Expected_Rate_Template_List (Discount_Type_ID, Program_Component_Name_ID, First_Parent_ID)
								VALUES (2, #arguments.compId#, #FirstParentID#)
							</cfquery>
						</cfloop>
					</cfif>


		</cfif>

		<cfreturn bCompNameExists />

   	</cffunction>

	<cffunction name="deactivate" output="false" hint="Function used to deactivate components.">

		<cfargument name="compIds" required="false" default="" />

		<cfquery datasource="#application.datasource#">
			UPDATE 	Program_Rebates_Component_Name
			SET		Active = 0
			WHERE	Program_Rebates_Component_Name_ID IN(#arguments.compIds#)
		</cfquery>

   	</cffunction>

	<cffunction name="activate" output="false" hint="Function used to activate components.">

		<cfargument name="compIds" required="false" default="" />

		<cfquery datasource="#application.datasource#">
			UPDATE 	Program_Rebates_Component_Name
			SET		Active = 1
			WHERE	Program_Rebates_Component_Name_ID IN(#arguments.compIds#)
		</cfquery>

   	</cffunction>

	<cffunction name="delete" output="false" hint="Function used to delete components.">

		<cfargument name="compIds" required="false" default="" />

		<cfquery datasource="#application.datasource#">
			UPDATE 	Program_Rebates_Component_Name
			SET		Deleted = 1
			WHERE	Program_Rebates_Component_Name_ID IN(#arguments.compIds#)
		</cfquery>

   	</cffunction>

	<cffunction name="update" output="false" hint="Function used to update components." returntype="numeric">

		<cfargument name="compId" required="false" default="" />
		<cfargument name="compName" required="false" default="" />
		<cfargument name="externalID" required="false" default="" />
		<cfargument name="Rebate_Percent_Option_ID" type="numeric" required="false" default="1" />
   		<cfargument name="operatingGroupId" required="false" default="0" />
		<cfargument name="Rebate_type" required="false" default="0" />
		<cfargument name="allowanceCodeId" required="false" default="0" />
		<cfargument name="requiredEffectiveRatePercent" required="false" default="0" />
		<cfargument name="selectedTemplateIdList" required="false" default="" />
		<cfargument name="Accrual_On" required="false" default="0" />
		<cfargument name="Exclude_Brokerage" required="false" default="0" />
		<cfargument name="Off_Invoice_On" required="false" default="0" />
		<cfargument name="User_ID" required="false" default="" />
		<cfargument name="GLList" required="false" default="" />
		<cfargument name="Rebate_Margin_Percent_Option_ID" type="numeric" required="false" default="1" />
		<cfargument name="Interface_as_Rate" required="false" default="1" />
		<cfargument name="Deduction_Account" required="false" default="" />
		<cfargument name="Payment_Account" required="false" default="" />
		<cfargument name="Auto_Pay_Net_Of_Cash_Discount" type="boolean" required="false" default="0" />
		<cfargument name="Auto_Pay_Net_Of_Freight_Allowance" type="boolean" required="false" default="0" />
		<cfargument name="Auto_Pay_Exclude_Credit_Type" type="boolean" required="false" default="0" />
		<cfargument name="Credit_Type_Select" type="string" required="false" default="" />
		<cfargument name="FOB_PayeeType1_DiscountType" type="string" required="false" default="" />
		<cfargument name="FOB_PayeeType2_DiscountType" type="string" required="false" default="" />
		<cfargument name="FOB_PayeeType3_DiscountType" type="string" required="false" default="" />
		<cfargument name="Recapture_Rate_From_Program_Budget" required="false" default="0" />
		<!--- D38536  :: Alternate recapture rates per component START--->
		<cfargument name="Alternate_Recapture_Rate" required="false" default="0" />
		<cfargument name="rate1" required="false" default="0" />
		<cfargument name="rate2" required="false" default="0" />
		<cfargument name="rate3" required="false" default="0" />
		<cfargument name="description1" required="false" default="0" />
		<cfargument name="description2" required="false" default="0" />
		<cfargument name="description3" required="false" default="0" />
		<cfargument name="AlternateRateTemplateList1" required="false" default="0" />
		<cfargument name="AlternateRateTemplateList2" required="false" default="0" />
		<cfargument name="AlternateRateTemplateList3" required="false" default="0" />
		<!--- D38536  :: Alternate recapture rates per component END--->
		<!---D40991 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work START--->
		<cfargument name="Update_BB_Expected_Rate" required="false" default="0" />
		<cfargument name="Expected_Rate" required="false" default="0" />
		<cfargument name="Program_Pays_To" required="false" default="0" />
		<cfargument name="Exclude_From_Recapture" required="false" default="0" />
		<!--- 43819 Recapture - operator exclusion list --->
		<cfargument name="Alternate_Recapture_By_Operator" required="false" default="0" />
		<!---D50514 :: Sysco - CF changes needed for enhancement in 45814.  CF Work START--->
		<cfargument name="Is_Retail" required="false" default="0">
		<cfargument name="Net_Out_of_Fixed_Price" required="false" default="0">
		<!---D50514 :: Sysco - CF changes needed for enhancement in 45814.  CF Work END--->
		<cfargument name="TemplatePaidToDefaultCFPages" required="false" default="" type="string"  />
		<cfargument name="TemplatePaidToDefaultRatesGrid" required="false" default="" type="string"  />
		<cfargument name="structTemplatePaidTo" required="false" default="structNew()" type="struct"  />
		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<cfargument name="DisplayID" required="false" default="0" />
		<cfargument name="DisplayDeductionAccount" required="false" default="0" />
		<cfargument name="DisplayPaymentAccount" required="false" default="0" />
		<!--- D58135 ::  Additional Component info displaye inside program END --->
		<cfargument name="ProgramLockTypeID" required="false" default="0" />

		<!---D79237 Rebate - OI and Redi START--->
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
		<!---D79237 Rebate - OI and Redi END--->

			<cfif arguments.Update_BB_Expected_Rate EQ 0>
				<cfset arguments.Expected_Rate = 0>
				<cfset arguments.Program_Pays_To = 0>
			</cfif>
		<!---D40991 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work END --->

		<cfset bCompNameExists = 0 />
		<cfset bProceedWithUpdate = 1 />

		<!---check to see if the name already exists--->
		<cfquery name="qCheckCompNames" datasource="#application.datasource#">
			SELECT	*
			FROM	Program_Rebates_Component_Name
			WHERE	0 = 0
			AND Program_Rebates_Component_Name = '#trim(arguments.compName)#'
			AND		Program_Rebates_Component_Name_ID != #arguments.compId#
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
		</cfif>

		<cfif bProceedWithUpdate>

			<cfif arguments.Rebate_Percent_Option_ID neq 1> <!--- 1=net sales, 2=gross sales --->
				<cfset arguments.Auto_Pay_Net_Of_Cash_Discount = 0 />
				<cfset arguments.Auto_Pay_Net_Of_Freight_Allowance = 0 />
				<cfset arguments.Auto_Pay_Exclude_Credit_Type = 0 />
			</cfif>
			<cfif arguments.Auto_Pay_Exclude_Credit_Type eq 0>
				<cfset arguments.Credit_Type_Select = "" />
			</cfif>

			<cfquery datasource="#application.datasource#">
				UPDATE 	Program_Rebates_Component_Name
				SET		Program_Rebates_Component_Name = '#arguments.compName#',
						External_ID = '#arguments.externalID#',
						Rebate_Percent_Option_ID = #arguments.Rebate_Percent_Option_ID#,
						Rebate_Margin_Percent_Option_ID = <cfqueryparam value="#arguments.Rebate_Margin_Percent_Option_ID#" cfsqltype="CF_SQL_INTEGER">,
						Operating_Group_ID = <cfqueryparam value="#arguments.operatingGroupId#" cfsqltype="CF_SQL_INTEGER" null="#arguments.operatingGroupId EQ 0#">,
						Allowance_Code_ID = <cfqueryparam value="#arguments.allowanceCodeId#" cfsqltype="CF_SQL_INTEGER" null="#arguments.allowanceCodeId EQ 0#">,
						Required_Effective_Rate_Percent = <cfqueryparam value="#arguments.requiredEffectiveRatePercent#" cfsqltype="CF_SQL_INTEGER">,
						Rebate_type =  <cfqueryparam value="#arguments.Rebate_type#" cfsqltype="CF_SQL_INTEGER">,
						Accrual_On = <cfqueryparam value="#arguments.Accrual_On#" cfsqltype="CF_SQL_INTEGER">,
						Exclude_Brokerage = <cfqueryparam value="#arguments.Exclude_Brokerage#" cfsqltype="CF_SQL_INTEGER">,
						Off_Invoice_On =  <cfqueryparam value="#arguments.Off_Invoice_On#" cfsqltype="CF_SQL_INTEGER">,
						Payment_Account = <cfqueryparam value="#arguments.Payment_Account#" cfsqltype="CF_SQL_VARCHAR">,
						Deduction_Account = <cfqueryparam value="#arguments.Deduction_Account#" cfsqltype="CF_SQL_VARCHAR">,
						Interface_As_Rate = <cfqueryparam value="#arguments.Interface_As_Rate#" cfsqltype="CF_SQL_BIT">,
						Auto_Pay_Net_Of_Cash_Discount = <cfqueryparam value="#arguments.Auto_Pay_Net_Of_Cash_Discount#" cfsqltype="cf_sql_bit">,
						Auto_Pay_Net_Of_Freight_Allowance = <cfqueryparam value="#arguments.Auto_Pay_Net_Of_Freight_Allowance#" cfsqltype="cf_sql_bit">,
						Auto_Pay_Exclude_Credit_Type = <cfqueryparam value="#arguments.Auto_Pay_Exclude_Credit_Type#" cfsqltype="cf_sql_bit">,
						Last_Edited_By = <cfqueryparam value="#arguments.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
						Last_Edited_Date = getdate()
						,Recapture_Rate_From_Program_Budget = <cfqueryparam value="#arguments.Recapture_Rate_From_Program_Budget#" cfsqltype="cf_sql_bit">
						,Alternate_Recapture_Rate = <cfqueryparam value="#arguments.Alternate_Recapture_Rate#" cfsqltype="cf_sql_bit">		<!--- D38536  :: Alternate recapture rates per component --->
						<!--- D40991 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work START--->
						,Update_BB_Expected_Rate = <cfqueryparam value="#arguments.Update_BB_Expected_Rate#" cfsqltype="cf_sql_bit">
						,Expected_Rate = <cfqueryparam value="#arguments.Expected_Rate#" cfsqltype="CF_SQL_INTEGER">
						,Program_Pays_To = <cfqueryparam value="#arguments.Program_Pays_To#" cfsqltype="CF_SQL_INTEGER">
						,Exclude_From_Recapture = <cfqueryparam value="#arguments.Exclude_From_Recapture#" cfsqltype="cf_sql_bit">
						,Alternate_Recapture_By_Operator = <cfqueryparam value="#arguments.Alternate_Recapture_By_Operator#" cfsqltype="cf_sql_bit">
						<!--- D40991 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work END--->
						<!---D50514 :: Sysco - CF changes needed for enhancement in 45814.  CF Work START--->
						,Is_Retail = <cfqueryparam value="#arguments.Is_Retail#" cfsqltype="CF_SQL_INTEGER">
						,Net_Out_of_Fixed_Price = <cfqueryparam value="#arguments.Net_Out_of_Fixed_Price#" cfsqltype="CF_SQL_INTEGER">
						<!---D50514 :: Sysco - CF changes needed for enhancement in 45814.  CF Work END--->
						<!--- D58135 ::  Additional Component info displaye inside program START--->
						,ID_on_ViewProgramPage = <cfqueryparam value="#arguments.DisplayID#" cfsqltype="cf_sql_bit">
						,DeductionAccount_on_ViewProgramPage = <cfqueryparam value="#arguments.DisplayDeductionAccount#" cfsqltype="cf_sql_bit">
						,PaymentAccount_on_ViewProgramPage	= <cfqueryparam value="#arguments.DisplayPaymentAccount#" cfsqltype="cf_sql_bit">
						<!--- D58135 ::  Additional Component info displaye inside program END--->
						,Program_Lock_Type_ID = <cfqueryparam value="#arguments.ProgramLockTypeID#" cfsqltype="CF_SQL_INTEGER">
						,Include_Second_Component = <cfqueryparam value="#arguments.Include_Second_Component#" cfsqltype="cf_sql_bit"><!---D79237 --->
						,Second_Component_Name_ID = <cfqueryparam value="#arguments.Second_Component_Name_ID#" cfsqltype="CF_SQL_INTEGER"><!---D79237 --->
						,Second_Component_Payment_Type_ID = <cfqueryparam value="#arguments.Second_Component_Payment_Type_ID#" cfsqltype="CF_SQL_INTEGER"><!---D79237 --->
						,Second_Component_GL_Account_ID = <cfqueryparam value="#arguments.Second_Component_GL_Account_ID#" cfsqltype="CF_SQL_INTEGER">
						,Second_Component_Payment_Cycle_ID = <cfqueryparam value="#arguments.Second_Component_Payment_Cycle_ID#" cfsqltype="CF_SQL_INTEGER">
						,TPO_Field = <cfqueryparam value="#arguments.TPO_Field#" cfsqltype="CF_SQL_INTEGER"> <!--- 95126--->
						,TPO_Rate_Type = <cfqueryparam value="#arguments.TPO_Rate_Type#" cfsqltype="CF_SQL_INTEGER"> <!--- 95126--->
						,Expected_Rate_Affect_Discount_Type = <cfqueryparam value="#arguments.Expected_Rate_Affect_Discount_Type#" cfsqltype="CF_SQL_INTEGER"> <!--- 91550--->
						,Expected_Rate_Apply_All_Templates = <cfqueryparam value="#arguments.Expected_Rate_Apply_All_Templates#" cfsqltype="CF_SQL_INTEGER"> <!--- 91550--->
					WHERE	Program_Rebates_Component_Name_ID = #arguments.compId#
			</cfquery>
							<!--- D38536  :: Alternate recapture rates per component START--->
							<cfset alternateRate = this.alternateRate(
																	compId= #arguments.compId#
																	,alternate_recapture_rate=#arguments.alternate_recapture_rate#
																	,rate1=#arguments.rate1#
																	,rate2=#arguments.rate2#
																	,rate3=#arguments.rate3#
																	,description1=#arguments.description1#
																	,description2=#arguments.description2#
																	,description3=#arguments.description3#
																	,AlternateRateTemplateList1=#arguments.AlternateRateTemplateList1#
																	,AlternateRateTemplateList2=#arguments.AlternateRateTemplateList2#
																	,AlternateRateTemplateList3=#arguments.AlternateRateTemplateList3#
																	)/>
						<!--- D38536  :: Alternate recapture rates per component END--->
			<cfif len(trim(arguments.GLList)) GT 0>
				<cfloop list="#arguments.GLList#" index="GL_Account_ID">
					<cfquery name="DeletefromMapping" datasource="#application.datasource#">
					DELETE FROM GL_Component_Mapping
					WHERE GL_Account_ID = '#GL_Account_ID#'
					AND Component_Name_ID = '#arguments.compId#'
					AND Discount_Type_ID = 2
					</cfquery>
				</cfloop>
			</cfif>

			<cfset templateManager.saveDiscountComponentTemplates(arguments.compId, 2, arguments.selectedTemplateIdList,
				arguments.TemplatePaidToDefaultCFPages, arguments.TemplatePaidToDefaultRatesGrid, arguments.structTemplatePaidTo) />

			<cfset saveCreditTypeExclusion(
					Rebate_Component_Name_ID = arguments.compId,
					Credit_Type_Select = arguments.Credit_Type_Select
					) />

			<cfset application.oController.getObject(path="mvc.Models.Settings.FOBPriceIndicatorManager",name="FOBPriceIndicatorManager",bReload= 1) />
			<!--- save auto pay fob price indicator list for payee = distributor --->
			<cfset application.oFOBPriceIndicatorManager.saveProgramComponentFOBPriceIndicator(
					payeeTypeId = 1,
					discountTypeId = 2,
					componentNameId = arguments.compId,
					FOBList = arguments.FOB_PayeeType1_DiscountType) />
			<!--- save auto pay fob price indicator list for payee = operator --->
			<cfset application.oFOBPriceIndicatorManager.saveProgramComponentFOBPriceIndicator(
					payeeTypeId = 2,
					discountTypeId = 2,
					componentNameId = arguments.compId,
					FOBList = arguments.FOB_PayeeType2_DiscountType) />
			<!--- save auto pay fob price indicator list for payee = broker --->
			<cfset application.oFOBPriceIndicatorManager.saveProgramComponentFOBPriceIndicator(
					payeeTypeId = 3,
					discountTypeId = 2,
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
					WHERE Program_Component_Name_ID  = #arguments.compId#
					AND Discount_Type_ID = 2
					AND NOT EXISTS (SELECT 1
																					FROM ##tmp_Program_Expected_Rate_Template_List T
																					Where T.FirstParentID = Program_Expected_Rate_Template_List.First_Parent_ID)

					INSERT INTO Program_Expected_Rate_Template_List (Discount_Type_ID, Program_Component_Name_ID, First_Parent_ID)
					SELECT 2, #arguments.compId#, FirstParentID
					FROM ##tmp_Program_Expected_Rate_Template_List T
					WHERE NOT EXISTS (SELECT 1
																								FROM Program_Expected_Rate_Template_List
																								WHERE Program_Expected_Rate_Template_List.Discount_Type_ID = 2
																								AND Program_Expected_Rate_Template_List.Program_Component_Name_ID  = #arguments.compId#
																								AND T.FirstParentID = Program_Expected_Rate_Template_List.First_Parent_ID)
					</cfquery>

			</cfif>
		</cfif>

		<cfreturn bCompNameExists />

   	</cffunction>

<!--- D38536  :: Alternate recapture rates per component START--->
	<cffunction name="alternateRate" output="false"  hint="Function Used to Insert Alternate rates AND Templates">
		<cfargument name="compId" required="false" default="" />
		<cfargument name="rate1" required="false" default="0" />
		<cfargument name="rate2" required="false" default="0" />
		<cfargument name="rate3" required="false" default="0" />
		<cfargument name="description1" required="false" default="0" />
		<cfargument name="description2" required="false" default="0" />
		<cfargument name="description3" required="false" default="0" />
		<cfargument name="AlternateRateTemplateList1" required="false" default="0" />
		<cfargument name="AlternateRateTemplateList2" required="false" default="0" />
		<cfargument name="AlternateRateTemplateList3" required="false" default="0" />

				 <cfquery name="alternateRateHistory" datasource="#application.datasource#">
					 INSERT INTO Alternate_Recapture_Rate_Setting_History
					 SELECT  Alternate_Recapture_Rate_Setting_ID , Program_Rebates_Component_Name_ID, Alternate_Recapture_Rate_Index, Alternate_Recapture_Rate_Label, Status, getdate()
					 FROM Alternate_Recapture_Rate_Setting
					 WHERE Program_Rebates_Component_Name_ID = #arguments.compid#

					INSERT INTO	Alternate_Recapture_Rate_Template_History
					SELECT Alternate_Recapture_Rate_Template_ID,Program_Rebates_Component_Name_ID,Alternate_Recapture_Rate_Index,First_Parent_ID, getdate()
					FROM Alternate_Recapture_Rate_Template
					WHERE Program_Rebates_Component_Name_ID = #arguments.compid#
				 </cfquery>
				 <cfquery name="AlternateRateDelete" datasource="#application.datasource#">
				 	DELETE FROM Alternate_Recapture_Rate_Setting WHERE Program_Rebates_Component_Name_ID = #arguments.compid#
				 	DELETE FROM Alternate_Recapture_Rate_Template WHERE Program_Rebates_Component_Name_ID = #arguments.compid#
				 </cfquery>


		<cfif arguments.alternate_recapture_rate>
				<cfloop from ="1" to="3" index="i">
						<cfif Evaluate("arguments.rate#i#")>
								<cfquery name="alternateRateInsert" datasource="#application.datasource#">
										INSERT INTO Alternate_Recapture_Rate_Setting
															(Program_Rebates_Component_Name_ID
															,Alternate_Recapture_Rate_Index
															,Alternate_Recapture_Rate_Label
															,Status)
										VALUES ( #arguments.compId#
														,#i#
														,'#Evaluate("arguments.description#i#")#'
														,0
													)
								</cfquery>

								<cfloop list="#Evaluate("arguments.AlternateRateTemplateList#i#")#" index="t" delimiters=",">
										<cfif len(t)>
												<cfquery name="alternateRateTemplateInsert" datasource="#application.datasource#">
														INSERT  INTO Alternate_Recapture_Rate_Template
																	(Program_Rebates_Component_Name_ID,
																	Alternate_Recapture_Rate_Index,
																	First_Parent_ID
																	)
														VALUES(	#arguments.compId#
																		,#i#
																		,#t#
																		)
												</cfquery>
										</cfif>
								</cfloop>
						</cfif>
				</cfloop>
		</cfif>
	</cffunction>
<!--- D38536  :: Alternate recapture rates per component END--->

	<cffunction name="canDelete" output="false" returntype="boolean" hint="Function used to verify if a component can be deleted or not.">

   		<cfargument name="nameID" type="numeric" required="false" default="" />

		<cfquery name="qCheckCompName" datasource="#application.datasource#">
			SELECT 	count(*) as count
			FROM 	Program_Rebates_Component
			WHERE 	Program_Rebates_Component_Name_ID = <cfqueryparam value="#arguments.nameID#" cfsqltype="CF_SQL_INTEGER" />
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
			FROM 	Program_Rebates_Component_Name
			WHERE 	Program_Rebates_Component_Name_ID = <cfqueryparam value="#arguments.compId#" cfsqltype="CF_SQL_INTEGER" />
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

	<cffunction name="rebate_type" output="false" returntype="string" hint="Function used to verify if a component has business rules or not.">

		<cfargument name="compId" type="numeric" required="false" default="" />

		<cfquery name="getrebatetype" datasource="#application.datasource#">
			SELECT 	rebate_type
			FROM 	Program_Rebates_Component_Name
			WHERE 	Program_Rebates_Component_Name_ID = <cfqueryparam value="#arguments.compId#" cfsqltype="CF_SQL_INTEGER" />
			AND 	Deleted = 0
		</cfquery>

		<!---if Has_Rules eq 1 then set bHasRules to true--->
			<cfset rebate_type = getrebatetype.rebate_type />


		<cfreturn rebate_type />

	</cffunction>

	<cffunction name="getPercentOptions" output="false" returntype="query">

		<cfquery name="qPercentOption" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Rebate_Percent_Option
			WHERE 	Deleted = 0
		</cfquery>

		<cfreturn qPercentOption />

	</cffunction>

	<cffunction name="getMarginPercentOptions" output="false" returntype="query">

		<cfquery name="qMarginPercentOption" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Rebate_Margin_Percent_Option
			WHERE 	Deleted = 0
		</cfquery>

		<cfreturn qMarginPercentOption />

	</cffunction>

	<cffunction name="isUSDANOIComp" returntype="boolean" output="false">
   		<cfargument name="componentNameID" required="true" default="0" />
		<cfparam name="request.isUSDANOIComp" default="0" />
		<cfparam name="request.componentNameID_isUSDANOIComp" default="0" />

		<CFIF request.componentNameID_isUSDANOIComp EQ arguments.componentNameID>
			<cfquery name="checkCompUSDAStatus" datasource="#application.datasource#">
				SELECT Is_USDA_NOI_Comp
				FROM Program_Rebates_Component_Name
				WHERE
				Program_Rebates_Component_Name_ID = '#arguments.componentNameID#'
				AND
				DELETED = 0
			</cfquery>

			<CFIF checkCompUSDAStatus.Is_USDA_NOI_Comp EQ 1 AND checkCompUSDAStatus.recordcount GT 0>
				<cfset request.isUSDANOIComp = 1>
			<CFELSE>
				<cfset request.isUSDANOIComp = 0>
			</CFIF>
			<cfset request.componentNameID_isUSDANOIComp = arguments.componentNameID />
		</CFIF>
		<cfreturn request.isUSDANOIComp />

   	</cffunction>

	<cffunction name="getUSDACompRate" returntype="numeric" output="false">

   		<cfargument name="BSA_Foodservice_Items_Master_ID" required="true" default="0" />

		<cfset tempReturn = 0>

		<CFIF arguments.BSA_Foodservice_Items_Master_ID NEQ "0">

			<cfstoredproc procedure="get_usdanoi_price" datasource="#application.datasource#">

				<cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="@@BSA_Foodservice_Items_Master_ID" value="#arguments.BSA_Foodservice_Items_Master_ID#" null="No">

				<cfprocparam type="Out" cfsqltype="CF_SQL_FLOAT" variable="usda_USDA_Price" dbvarname="@@USDA_Price" null="No">
				<cfprocparam type="Out" cfsqltype="CF_SQL_VARCHAR" variable="usda_UOM" dbvarname="@@UOM" null="No">
				<cfprocparam type="Out" cfsqltype="CF_SQL_INTEGER" variable="usda_Yield_Out" dbvarname="@@Yield_OUT" null="No">
				<cfprocparam type="Out" cfsqltype="CF_SQL_FLOAT" variable="usda_PTV_CS" dbvarname="@@PTV_CS" null="No">
				<cfprocparam type="Out" cfsqltype="CF_SQL_FLOAT" variable="usda_PTV_LB" dbvarname="@@PTV_LB" null="No">
				<cfprocparam type="Out" cfsqltype="CF_SQL_FLOAT" variable="usda_PTV_RM" dbvarname="@@PTV_RM" null="No">

			</cfstoredproc>

			<CFSET tempReturn = usda_USDA_Price>
		</CFIF>


		<cfreturn tempReturn />

   	</cffunction>

	<cffunction name="saveCreditTypeExclusion" returntype="void" output="false">
		<cfargument name="Rebate_Component_Name_ID" type="numeric" required="true" />
		<cfargument name="Credit_Type_Select" type="string" required="true" />

		<cfquery name="qDeleteExistingCreditTypeExclusions" datasource="#application.datasource#">
			DELETE 	Program_Rebates_Credit_Type_Exclusion
			WHERE	Program_Rebates_Component_Name_ID = <cfqueryparam value="#Rebate_Component_Name_ID#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfif arguments.Credit_Type_Select neq "">
			<cfloop list="#arguments.Credit_Type_Select#" index="creditTypeId">
				<cfquery name="qInsertCreditTypeExclusion" datasource="#application.datasource#">
					INSERT INTO Program_Rebates_Credit_Type_Exclusion (Program_Rebates_Component_Name_ID, Credit_Type_ID)
					VALUES (
					<cfqueryparam value="#Rebate_Component_Name_ID#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#creditTypeId#" cfsqltype="cf_sql_integer">
					)
				</cfquery>
			</cfloop>
			<cfquery name="qInsertCreditTypeExclusionHistory" datasource="#application.datasource#">
				INSERT INTO Program_Rebates_Credit_Type_Exclusion_History (Program_Rebates_Credit_Type_Exclusion_ID, Program_Rebates_Component_Name_ID, Credit_Type_ID)
				SELECT	Program_Rebates_Credit_Type_Exclusion_ID, Program_Rebates_Component_Name_ID, Credit_Type_ID
				FROM	Program_Rebates_Credit_Type_Exclusion
				WHERE	Program_Rebates_Component_Name_ID = <cfqueryparam value="#Rebate_Component_Name_ID#" cfsqltype="cf_sql_integer">
			</cfquery>
		</cfif>

	</cffunction>

	<cffunction name="getCreditTypeExclusion" returntype="query" output="false">
		<cfargument name="Rebate_Component_Name_ID" type="numeric" required="true" />

		<cfquery name="qGetCreditTypeExclusionHistory" datasource="#application.datasource#">
			SELECT	Program_Rebates_Component_Name_ID, Credit_Type_ID
			FROM	Program_Rebates_Credit_Type_Exclusion
			WHERE	Program_Rebates_Component_Name_ID = <cfqueryparam value="#Rebate_Component_Name_ID#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfreturn qGetCreditTypeExclusionHistory />

	</cffunction>

	<!--- As of now, this function is not being used, but can be used in the future --->
	<!--- Returns component level information for a program --->
	<cffunction name="getRebateComponentData" returntype="query" output="false">
		<cfargument name="programID" type="numeric" required="true" default="0">
		<cfargument name="Rebate_Component_ID" type="numeric" required="false" default="0" />

		<cfquery name="qGetRebateComponentData" datasource="#application.datasource#">
		SELECT	Program_Rebates_Component_Name.Off_Invoice_On,
				Program_Rebates_Component_Name.Program_Rebates_Component_Name,
				Payment_Type.Payment_Type_Name,
				Payment_Type.Restrict_From_Billback,
				Payment_Type.Is_Auto_Pay,
				Program_Rebates_Component.Component_Paid_To,
				Program_Rebates_Component.Claim_Mechanics,
				Program_Rebates_Component.Program_Rebates_Component_ID,
				Program_Rebates_Component.Vendor_Selection,
				Program_Rebates_Component.Vendor_Master_ID,
				GL_Account.GL_Account,
				GL_Account.GL_Account_Desc,
				isnull(nullif(Program_Rebates_Component.Payee_Type,''),0) As Payee_Selection
		FROM 	Program_Rebates_Component
			LEFT JOIN Payment_Type ON
			Payment_Type.Payment_Type_ID = Program_Rebates_Component.Claim_Mechanics
			LEFT JOIN GL_Account
			ON GL_Account.GL_Account_ID = Program_Rebates_Component.GL_Account_ID
			INNER JOIN Program_Rebates_Component_Name ON
			Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID
		WHERE		Program_Rebates_Component.Program_ID = '#arguments.programID#'
		<cfif arguments.Rebate_Component_ID neq 0>
		AND 		Program_Rebates_Component.Program_Rebates_Component_ID = '#arguments.Rebate_Component_ID#'
		</cfif>
		AND		Program_Rebates_Component.Deleted = 0
		</cfquery>

		<cfreturn qGetRebateComponentData />
	</cffunction>

	<!--- Check if payee on program is not in the list of program distributors. --->
	<cffunction name="IsPayeeNotOnProgramForAutoPayRebate" returntype="boolean" output="false">
		<cfargument name="programID" type="numeric" required="true" default="0">

		<cfset var IsPayeeNotOnProgram = 0>

		<cfquery name="qIsPayeeNotOnProgramForAutoPayRebate" datasource="#application.datasource#">
		/* DISTRIBUTOR PAYEE */
		SELECT 1
		FROM 	Program_Rebates_Component
		INNER JOIN Payment_Type ON
		Payment_Type.Payment_Type_ID = Program_Rebates_Component.Claim_Mechanics
		WHERE Program_Rebates_Component.Program_ID =  '#arguments.programID#'
		AND	Program_Rebates_Component.Deleted = 0
		/* payee is a "distributor". */
		AND isnull(nullif(Program_Rebates_Component.Payee_Type,''),0) = 1
		/* "Auto pay" must be ON for the claim mechanism. */
		AND Payment_Type.Is_Auto_Pay = 1
		/* Payee needs to be selected. */
		AND Program_Rebates_Component.Vendor_Selection = 1
		AND NOT EXISTS
		(
			SELECT 1
			FROM Contract_Distributors
			WHERE Contract_Distributors.Contract_Main_ID =  '#arguments.programID#'
			AND Contract_Distributors.Deleted = 0
			/* "Vendor_Master_ID" column stores the "distribuor_id" in the "Program_Rebates_Component." table,
			when the payee for the component is a distributor.
			One needs to click on "edit" link for the component, select an "Auto Pay" for the "claim mechanism",
			and then for the "single payee" option, select a distributor.
			*/
			AND Program_Rebates_Component.Vendor_Master_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
		)

		UNION

		/* VENDOR PAYEE */
		SELECT 1
		FROM 	Program_Rebates_Component
		INNER JOIN Payment_Type ON
		Payment_Type.Payment_Type_ID = Program_Rebates_Component.Claim_Mechanics
		WHERE Program_Rebates_Component.Program_ID =  '#arguments.programID#'
		AND	Program_Rebates_Component.Deleted = 0
		/* payee is a "vendor". */
		AND isnull(nullif(Program_Rebates_Component.Payee_Type,''),0) = 5
		/* "Auto pay" must be ON for the claim mechanism. */
		AND Payment_Type.Is_Auto_Pay = 1
		/* Payee needs to be selected. */
		AND Program_Rebates_Component.Vendor_Selection = 1
		/* check default vendor or same ship_to and vendor.  */
		AND NOT EXISTS
		(
			SELECT 1
			FROM Contract_Distributors
			INNER JOIN BSA_Foodservice_Customers
			ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
			INNER JOIN Vendor_Master
			/* One needs to click on "edit" link for the component, select an "Auto Pay" for the "claim mechanism",
			and then for the "single payee" option, select a vendor.
			*/
			ON Program_Rebates_Component.Vendor_Master_ID = Vendor_Master.Vendor_Master_ID
			WHERE Contract_Distributors.Contract_Main_ID =  '#arguments.programID#'
			AND Contract_Distributors.Deleted = 0
			/* Check whether "default vendor" for the distributor is the payee. */
			AND
			(
			BSA_Foodservice_Customers.Default_Vendor_ID = Vendor_Master.Vendor_ID
			OR
			/* Check whether any of the "ship_to" is the same as the selected vendor on the rebate component. */
			BSA_Foodservice_Customers.Shr_Ship_To =  Vendor_Master.Vendor_ID
			)
		)
		/* check vendor */
		AND NOT EXISTS
		(
			SELECT 1
			FROM Contract_Distributors
			INNER JOIN Vendor_Dist_Oper
			ON Vendor_Dist_Oper.Distributor_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
			AND Vendor_Dist_Oper.Deleted = 0
			INNER JOIN Vendor_Master
			/* One needs to click on "edit" link for the component, select an "Auto Pay" for the "claim mechanism",
			and then for the "single payee" option, select a vendor.
			*/
			ON Program_Rebates_Component.Vendor_Master_ID = Vendor_Master.Vendor_Master_ID
			WHERE Contract_Distributors.Contract_Main_ID =  '#arguments.programID#'
			AND Contract_Distributors.Deleted = 0
			/* Check whether the "vendor" for the distributor is the payee. */
			AND Vendor_Dist_Oper.Vendor_ID = Vendor_Master.Vendor_ID
		)
		</cfquery>

			<cfif qIsPayeeNotOnProgramForAutoPayRebate.recordcount>
				<cfset var IsPayeeNotOnProgram = 1>
			</cfif>

		<cfreturn IsPayeeNotOnProgram />
	</cffunction>
<!--- 91550 :: Enhancement: Template-specific Expected Rate Adjustments START --->
	<cffunction name="getExpectedRateTemplates" returntype="query" output="false">
		<cfargument name="CompID" type="numeric" required="true" default="0">

		<cfquery name="qGetRebateComponentData" datasource="#application.datasource#">
			SELECT First_Parent_ID
			FROM Program_Expected_Rate_Template_List
			WHERE Discount_Type_ID = 2
			AND Program_Component_Name_ID = #arguments.CompID#
		</cfquery>
		<cfreturn qGetRebateComponentData/>
		</cffunction>
<!--- 91550 :: Enhancement: Template-specific Expected Rate Adjustments END --->
</cfcomponent>
