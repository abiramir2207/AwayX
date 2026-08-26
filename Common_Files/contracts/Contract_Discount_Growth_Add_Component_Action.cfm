<!--- lock checker --->
<CFSET LockChecker_CID  = FORM.Program_ID>
<cfparam name="form.EZTemplate" default="0">

<cfif form.EZTemplate EQ 0>
<CFINCLUDE TEMPLATE="LockChecker_For_Popups.cfm">
</cfif>
<!--- lock checker --->

<cfparam name="form.Comparison_Type" default="0">
<cfparam name="form.Sample_Period" default="">
<cfparam name="Seperate_Volume_Pool" default="0">
<cfparam name="form.Component_Paid_To" default="1">
<!---Program_Growth_Comparison_Period_UOM is for "Amount" OR "Volume" for growth tiers calculation--->
<cfparam name="form.Program_Growth_Comparison_Period_UOM" default ="0">
<cfparam name="form.VendorSelection" default="">
<cfparam name="form.Claim_Mechanics" default="">
<cfparam name="form.GL_Account_ID" default="0">
<cfparam name="form.Vendor_Master_ID" default="">
<cfparam name="form.Payee_Selection" default="">
<cfparam name="form.Min_Purchase_Requirement" default="0">
<cfparam name="form.Min_Purchase_Value" default="">
<cfparam name="form.Growth_Calculation" default="0"/><!--- D46874 :: New Growth Option (Growth Calculation) START --->
<!--- If the option "Pay each entity individually" or "Pay custom combinations" is selected, delete the selected vendor (if any) --->
<cfif form.VendorSelection eq 2 OR form.VendorSelection eq 3>
	<cfset form.Vendor_Master_ID = 0>
</cfif>

<cfif FORM.VendorSelection IS "true">
	<cfset FORM.VendorSelection = 1>
</cfif>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfif form.deletedateexclusions EQ 1>
	<cfquery name="GetSettings" datasource="#application.datasource#">
		SELECT 	Program_Control_Panel_Options.Date_Exclusions_ON
		FROM 	Program_Control_Panel_Options
		INNER JOIN Contract_Main 
		ON 	Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
		WHERE  Contract_Main_ID = #form.program_id#
	</cfquery>

	<cfif GetSettings.Date_Exclusions_ON EQ 1>
		<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
		<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(form.program_id,0)>
		<cfif form.deletedateexclusions EQ 1>
			<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
				<cfquery name="deletedateexclusions" datasource="#application.datasource#">
					update contract_main
					set deleted = 1
					where contract_main_id in (#valuelist(getDateExclusionprogramIDs.revision_program_id)#)
				</cfquery>
				<cfquery name="deletedateexclusions" datasource="#application.datasource#">
					update program_exclusions
					set deleted = 1
					where revision_program_id in (#valuelist(getDateExclusionprogramIDs.revision_program_id)#)
				</cfquery>
			</CFIF>
		</cfif>
	</cfif>
</cfif>

<CFSET Running_Tier_ID_List = "">

	<cfset useLakebaseForGetComponentInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components_name")>
<cfif useLakebaseForGetComponentInfo>
	<cftry>
		<cfset GetComponentInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_growth_components_name", {
				"program_growth_components_name_id" = "eq.#FORM.Growth_Component_Name_ID#",
				"select" = "external_id"
			}), "external_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetComponentInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetComponentInfo>
<cfquery name="GetComponentInfo" datasource="#application.datasource#">
		SELECT External_ID
		FROM Program_Growth_Components_Name
		WHERE Program_Growth_Components_Name_ID = '#FORM.Growth_Component_Name_ID#'
	</cfquery>
</cfif>
	<cfif Form.Min_Purchase_Requirement EQ 0>
		<cfset Form.Min_Purchase_Value = "NULL" />
	</cfif>
<!--- save component information --->
<CFIF FORM.Component_ID EQ 0>
	<CFQUERY NAME="addNewComp" datasource="#application.datasource#">
		INSERT INTO Program_Growth_Components(
					 Program_ID
					,Tier_Count
					,Component_Name
					,Program_Growth_Components_Name_Id
					,Component_Description
					,Rate_Type
					,component_uom
					,Comparison_Type
					,Sample_Period
					,Component_Paid_To
					,Program_Growth_Comparison_Period_UOM_ID
					,IsParent, Is_Rate
					,Is_Volume
					,Component_External_ID
					,Vendor_Selection
					,Claim_Mechanics
					,GL_Account_ID
					<cfif Form.Vendor_Master_ID neq "">,Vendor_Master_ID</cfif>
					,Payee_Type
					,Min_Purchase_Requirement
					,Min_Purchase_Value
					,Growth_Calculation <!--- D46874 :: New Growth Option (Growth Calculation) --->
		)
		VALUES(
				'#FORM.Program_ID#'
				,'#FORM.Tier_Count#'
				,'#FORM.Component_Name#'
				,'#FORM.Growth_Component_Name_ID#'
				,'#FORM.Component_Description#'
				, '#FORM.Rate_Type#'
				, '#FORM.component_uom#'
				, '#FORM.Comparison_Type#'
				, '#FORM.Sample_Period#'
				, #form.Component_Paid_To#
				,'#FORM.Program_Growth_Comparison_Period_UOM#'
				, 1
				, 1
				,<cfif Seperate_Volume_Pool IS 0>1<cfelse>0</cfif>
				,'#GetComponentInfo.External_ID#'
				,'#FORM.VendorSelection#'
				,'#Form.Claim_Mechanics#'
				,'#Form.GL_Account_ID#' 
				<cfif Form.Vendor_Master_ID neq "">,<cfif Form.VendorSelection eq 1 AND form.Vendor_Master_ID NEQ 0>'#Form.Vendor_Master_ID#'<cfelse>NULL</cfif></cfif>
				,'#Form.Payee_Selection#'
				,#Form.Min_Purchase_Requirement#
				, #Form.Min_Purchase_Value#
				,#form.Growth_Calculation#<!--- D46874 :: New Growth Option (Growth Calculation) --->
		)
	</CFQUERY>
	<CFSET temp_Component_ID = addNewComp.A_ID>
	<!---handle for payment cycle--->
	<cfif appSettings.getPaymentCycleAtDiscountType()>
		<cfset useLakebaseForQGetCompNameId = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components")>
		<cfif useLakebaseForQGetCompNameId>
			<cftry>
				<cfset qGetCompNameId = application.oLakebase.toQuery(
					application.oLakebase.selectRows("program_growth_components", { "deleted" = "eq.false", "program_growth_component_id" = "eq.#temp_Component_ID#", "select" = "growth_component_name_id" })
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForQGetCompNameId = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForQGetCompNameId>
			<cfquery name="qGetCompNameId" datasource="#application.datasource#">
				SELECT 	Growth_Component_Name_ID
				FROM 	Program_Growth_Components
				WHERE Deleted = 0
				AND 	Program_Growth_Component_ID = '#temp_Component_ID#'
			</cfquery>
		</cfif>
		<cfset FORM.Comp_Name_ID = qGetCompNameId.Growth_Component_Name_ID />
		<cfset useLakebaseForqUpdateGrowthRevCompId = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components")>
<cfif useLakebaseForqUpdateGrowthRevCompId>
	<cftry>
		<cfset application.oLakebase.updateRows("program_growth_components",
			{
				"deleted" = "eq.0",
				"program_growth_component_id" = "eq.#temp_Component_ID#"
			},
			{
				"growth_revision_comp_id" = "#FORM.Comp_Name_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdateGrowthRevCompId = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdateGrowthRevCompId>
<cfquery name="qUpdateGrowthRevCompId" datasource="#application.datasource#">
			UPDATE 	Program_Growth_Components
			SET			Growth_Revision_Comp_ID = #FORM.Comp_Name_ID#
			WHERE 	Deleted = 0
			AND 	Program_Growth_Component_ID = '#temp_Component_ID#'
		</cfquery>
</cfif>
	</cfif>
<CFELSE>

	<CFQUERY NAME="updateComponentInfo" datasource="#application.datasource#">
		UPDATE Program_Growth_Components
		SET	Program_ID 				= '#FORM.Program_ID#'
			,Tier_Count 				= '#FORM.Tier_Count#'
			,Component_Name 			= '#FORM.Component_Name#'
			,Component_Description 	= '#FORM.Component_Description#'
			,Rate_Type				= '#FORM.Rate_Type#'
			,Component_UOM			= '#FORM.component_uom#'
			,Comparison_Type			= '#FORM.Comparison_Type#'
			,Sample_Period			= '#FORM.Sample_Period#'
			,Component_Paid_To       = #form.Component_Paid_To#
			,Component_External_ID	= '#GetComponentInfo.External_ID#'
			,Program_Growth_Comparison_Period_UOM_ID = '#FORM.Program_Growth_Comparison_Period_UOM#'
			,Vendor_Selection = '#FORM.VendorSelection#'
			,Claim_Mechanics = '#Form.Claim_Mechanics#'
			,Payee_Type = '#Form.Payee_Selection#',
			GL_Account_ID = '#FORM.GL_Account_ID#'
			<cfif Form.Vendor_Master_ID neq "">
			,Vendor_Master_ID = <cfif form.Vendor_Master_ID NEQ 0>'#FORM.Vendor_Master_ID#'<cfelse>NULL</cfif>
			</cfif>
			<cfif appSettings.getGrowthExpansion1()>
				,IsParent				= 1
				,Is_Rate 				= 1
				<cfif Seperate_Volume_Pool IS 0>
				,Is_Volume		= 1
				<cfelse>
				,Is_Volume		= 0
				</cfif>
			</cfif>
			,Min_Purchase_Requirement = #Form.Min_Purchase_Requirement#
			,Min_Purchase_Value		= #Form.Min_Purchase_Value#
			,Growth_Calculation = #form.Growth_Calculation# <!--- D46874 :: New Growth Option (Growth Calculation) --->
		WHERE Program_Growth_Component_ID	=	'#FORM.Component_ID#'
	</CFQUERY>
	<CFSET temp_Component_ID = FORM.Component_ID>
</CFIF>
<!--- END save component information --->

<CFLOOP INDEX="TierCount" FROM="1" TO="#FORM.TIER_COUNT#" STEP="1">
	<CFIF isdefined("FORM.Tier_#TierCount#_ID")>
		<CFSET Tier_ID = evaluate("FORM.Tier_#TierCount#_ID")>
	<CFELSE>
		<CFSET Tier_ID = 0>
	</CFIF>
	<CFSET temp_Tier_Count				= TierCount>
	<CFSET temp_Tier_RangeStart			= evaluate("FORM.TIER_#TierCount#_RANGESTART")>
	<CFSET temp_Tier_RangeEnd			= evaluate("FORM.TIER_#TierCount#_RANGEEND")>
	<CFSET temp_Tier_Growth_Amount		= evaluate("FORM.TIER_#TierCount#_GROWTHAMOUNT")>

	<CFIF Tier_ID EQ 0>
	<!--- INSERT A NEW ONE --->
		<CFQUERY NAME="saveTiers" datasource="#application.datasource#">
			INSERT INTO Program_Growth_Component_Tiers(
				Program_Growth_Component_ID,
				Program_ID,
				Tier_Number,
				Range_Start,
				Range_End,
				Growth_Amount
			)
			VALUES(
				'#temp_Component_ID#'
				,'#FORM.Program_ID#'
				,'#temp_Tier_Count#'
				,'#temp_Tier_RangeStart#'
				,<cfif temp_Tier_RangeEnd GT 9999999>'*'<cfelse>'#temp_Tier_RangeEnd#'</cfif>
				,'#temp_Tier_Growth_Amount#'
			)
		</CFQUERY>
		<CFSET Running_Tier_ID_List = listappend(Running_Tier_ID_List,saveTiers.INS_Program_Growth_Component_Tier_ID, ",")>
	<CFELSE>
	<!--- Update the existing component --->
		<CFQUERY NAME="updateTier" datasource="#application.datasource#">
			UPDATE Program_Growth_Component_Tiers
			SET 	Range_Start 	= 	'#temp_Tier_RangeStart#',
				Range_End		=	<cfif temp_Tier_RangeEnd GT 9999999>'*'<cfelse>'#temp_Tier_RangeEnd#'</cfif>,<!--- D44000 --->
				Growth_Amount 	=	'#temp_Tier_Growth_Amount#'
			WHERE Program_Growth_Component_Tier_ID = '#Tier_ID#'
		</CFQUERY>
		<CFSET Running_Tier_ID_List = listappend(Running_Tier_ID_List,Tier_ID, ",")>
	</CFIF>

</CFLOOP>
	<CFIF listlen(Running_Tier_ID_List) GT 0>
		<CFQUERY NAME="getAllCompTiers" datasource="#application.datasource#">
			UPDATE Program_Growth_Component_Tiers
			SET DELETED = 1
			WHERE Program_Growth_Component_Tier_ID NOT IN(#replace(listqualify(Running_Tier_ID_List, "'", ","), '"', "'", "ALL")#) 
			AND Program_Growth_Component_ID = '#temp_Component_ID#'
		</CFQUERY>
	</CFIF>

<!------ Start Clause Code ----->
<cfset discountTypeId = 4>
<cfset programId = Form.Program_ID>
<cfinclude template="/Clause_Library/Clause_Discount_Type_Add_Remove.cfm">
<!------ End  Clause Code ----->

<!------ update discount type payment cycle ----->
<cfif appSettings.getPaymentCycleAtDiscountType()>
	<cfif not isDefined("FORM.PaymentCycle") and isDefined("FORM.hiddenPaymentCycle")>
		<cfset FORM.PaymentCycle = FORM.hiddenPaymentCycle >
	</cfif>
	<cfset paymentCycleManager = CreateObject("component", "components.programs.PaymentCycleManager").init() />
	<cfset paymentCycleManager.savePaymentCycle(Form.Program_ID, 4, FORM.PaymentCycle, temp_Component_ID) />
</cfif>

<cfif form.Action IS "Edit">
	<cflocation url="Contract_Discount_Growth.cfm?CID=#Form.CID#&EZTemplate=#form.EZTemplate#">
<cfelseif Seperate_Volume_Pool IS 1>
	<cflocation url="Contract_Discount_Growth_Add_Volume_Items.cfm?CompID=#temp_Component_ID#&Program_ID=#FORM.Program_ID#&CID=#FORM.CID#&EZTemplate=#form.EZTemplate#">
<cfelse>
	<cflocation url="contract_discount_Growth_add_component_products.cfm?CompID=#temp_Component_ID#&Program_ID=#FORM.Program_ID#&CID=#FORM.CID#&EZTemplate=#form.EZTemplate#">
</cfif>