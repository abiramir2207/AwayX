<!---
FILE:
FILENAME: 	components\programs\templates\TemplateManager.cfc
CREATED: 	??/??/200? - ??
EDITED:		10/14/2008 - RBL [17289 > 16314: Margin Analysis - Add Contract Price - follow-up]

FUNCTIONALITY:
DEPENDENCIES:
--->

<cfcomponent hint="Manages Campaign" extends="components.Base">


	<cffunction name="init" output="false" returntype="components.programs.template.TemplateManager">

		<cfreturn this />

	</cffunction>

	<cffunction name="get" output="false">

		<cfargument name="id" required="false" default=0 type="numeric" />

		<cfset this.template = CreateObject("component","components.programs.template.Template").init() />

		<cfif arguments.id>

			<cfquery name="qGetTemplate" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
				SELECT 	ProgramControl_Panel_Options_ID,
						Active,
						Generic_Type,
						Created_Type,
						Check_Duplicate_Program,
						duplicate_program_action,
						Revision_Not_Allowed,
						Date_Updated,
                        <!--- 17289 > 16314 follow up [begin] --->
                        Discount_Fixed_Prices,
                        <!--- 17289 > 16314 follow up [end] --->
						EZButton_On,
						EZ_Contract_Id,
						Pullbacks_On,
						is_pullback_corporate_deal,
						EZprogram_editcomponent,
						BB_D_Purchase_Period_OverRide,
						Discount_Fixed_Prices_Freight,
						First_Parent_ID,
						Template_Parent_ID,
			            Discount_Rebate_Max_Rate_On,
			            EzButton_Update_With_Latest_Template_Settings_On_Revise,
						Market_Price,
						Specify_Operators,
						Group_Deal,
						Specify_Distributor_Groups,
						EzButton_Enter_Beyond_Max_Rates,
						EzButton_Default_Show_Item_Rates
						,EzButton_Auto_Approve_On                 <!---27333--->
						,Is_Fiscal                                <!---25715--->
						,Single_Component_Per_Discount_Type
						,EzButton_Max_Rate_Consider
						,letters_accepted_by
						,Default_rate_equal_to_zero <!---	36607--->
						,DispalyPaysToOnViewProgPage
						,Fixed_Rebate_Grid_Option
						,Discount_Rebates_Group_Level
						,EZ_Button_Rate_ID
						,Retail_Planner
						,Filter_EZButton_Products <!--- 63628 --->
						,Disable_Duplicate_Check_For_Revisions
						,Allow_Vendor_Only
				FROM	Program_Control_Panel_Options<!--- D30064:  Max Rate to consider Rebate and Lump Sum --->
				WHERE 	Deleted = 0
				AND		ProgramControl_Panel_Options_ID = #arguments.id#
			</cfquery>

			<cfloop query="qGetTemplate">

				<cfset this.template.setId(ProgramControl_Panel_Options_ID) />
				<cfset this.template.setGenericType(Generic_Type) />
				<cfset this.template.setCreatedType(Created_Type) />
				<cfset this.template.setActive(Active) />
                <!--- 17289 > 16314 follow up [begin] --->
                <cfset this.template.setDiscount_Fixed_Prices(Discount_Fixed_Prices) />
                <!--- 17289 > 16314 follow up [end] --->
				<cfset this.template.setDuplicate(Check_Duplicate_Program) />
				<cfset this.template.setDupAction(duplicate_program_action) />
				<cfset this.template.setRevisionNotAllowed(Revision_Not_Allowed) />
				<cfset this.template.setEZButtonOn(EZButton_On) />
				<cfset this.template.setEZContractId(EZ_Contract_Id) />
				<cfset this.template.setEZprogrameditcomponent(EZprogram_editcomponent) />
				<cfset this.template.setPullbacksOn(Pullbacks_On) />
				<cfset this.template.setcorporatedeal(is_pullback_corporate_deal) />
				<cfset this.template.setBBDPurchasePeriodOverRide(BB_D_Purchase_Period_OverRide) />
				<cfset this.template.setFixedFreight(Discount_Fixed_Prices_Freight)/>
				<cfset this.template.setFirstParentID(First_Parent_ID)/>
				<cfset this.template.setTemplateParentID(Template_Parent_ID)/>
				<cfset this.template.setMarketPrice(Market_Price)/>
        		<cfset this.template.setDiscountRebateMaxRateOn(Discount_Rebate_Max_Rate_On) />
       		 	<cfset this.template.setEzButtonUpdateWithLatestTemplateSettingsOnRevise(EzButton_Update_With_Latest_Template_Settings_On_Revise) />
				<cfset this.template.setTemplateFilters()/>
				<cfset this.template.setPlannerProgram(Retail_Planner)/>
				<cfset this.template.Specify_Operators = qGetTemplate.Specify_Operators />
				<cfset this.template.Allow_Product_Group_Search = qGetTemplate.Group_Deal />
				<cfset this.template.Allow_Distributor_Group_Search = qGetTemplate.Specify_Distributor_Groups />
				<!---
     			Dev Notes: D25709/Anand Rao/17-Mar-2011
    			EZ button changes
				--->
			 	<cfset this.template.EzButton_Enter_Beyond_Max_Rates = qGetTemplate.EzButton_Enter_Beyond_Max_Rates />
				<cfset this.template.EzButton_Default_Show_Item_Rates = qGetTemplate.EzButton_Default_Show_Item_Rates />
				<cfset this.template.EzButton_Auto_Approve_On = qGetTemplate.EzButton_Auto_Approve_On />    <!---27333--->
				<cfset this.template.Is_Fiscal = qGetTemplate.Is_Fiscal />        <!---25715--->
				<cfset this.template.Single_Component_Per_Discount_Type = qGetTemplate.Single_Component_Per_Discount_Type />
				<cfset this.template.EzButton_Max_Rate_Consider = qGetTemplate.EzButton_Max_Rate_Consider>   <!--- D30064:  Max Rate to consider Rebate and Lump Sum --->
				<cfset this.template.Default_rate_equal_to_zero = qGetTemplate.Default_rate_equal_to_zero />        <!---36607--->
				<cfset this.template.DispalyPaysToOnViewProgPage = qGetTemplate.DispalyPaysToOnViewProgPage />
				<cfset this.template.Fixed_Rebate_Grid_Option = qGetTemplate.Fixed_Rebate_Grid_Option />
				<cfset this.template.Discount_Rebates_Group_Level = qGetTemplate.Discount_Rebates_Group_Level />
				<cfset this.template.EZ_Button_Rate_ID			= qGetTemplate.EZ_Button_Rate_ID />
				<cfset this.template.Filter_EZButton_Products			= qGetTemplate.Filter_EZButton_Products/> <!--- 63628 --->
				<cfset this.template.Disable_Duplicate_Check_For_Revisions			= qGetTemplate.Disable_Duplicate_Check_For_Revisions />
				<cfset this.template.Allow_Vendor_Only			= qGetTemplate.Allow_Vendor_Only />
			</cfloop>

		</cfif>

		<cfreturn this.template />

	</cffunction>

	<cffunction name="getProgramTemplate" output="false" returntype="query">

		<cfargument name="programId" required="true" type="numeric" />

		<cfif arguments.programId>

			<cfquery name="qGetProgramTemplate" datasource="#application.datasource#">
				SELECT 	PCPO.*,
						CM.contract_number,
						CM.contract_title,
						CM.Template_Filters_Id,
						ISNULL(CM.Currency_Conversion_Factor, 0) AS Conversion_Factor,
						TRS. Payment_Frequency_Changes,
						TRS.Claim_Mechanic_Changed
				FROM	Program_Control_Panel_Options PCPO
				INNER JOIN Contract_Main CM ON
					CM.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID AND
					CM.Contract_Main_ID = #arguments.programId#
				LEFT JOIN Template_Revision_Settings TRS ON
					TRS.Template_Id = PCPO.ProgramControl_Panel_Options_ID  AND  TRS.Revision_Setting_Deleted = 0
				WHERE 	PCPO.Deleted = 0
			</cfquery>
		</cfif>

		<cfreturn qGetProgramTemplate />

	</cffunction>
 
	<cffunction name="getAll" output="false" access="remote">

		<cfargument name="orderCriteria" required="false" type="numeric" default="0" />
		<cfargument name="businessSegmentId" required="false" type="string" default="0" />

		<cfquery name="qGetAllTemplate" datasource="#application.datasource#">
			SELECT 	ProgramControl_Panel_Options_ID,
					Generic_Type,
					Created_Type,
					First_Parent_ID,
					BidRequestStatusOn,
					BidRequestStatusChangePgmStatus,
					Program_Description,
					ProgramControl_Panel_Options_ID Template_ID,
					Approval_Considerations_ID
			FROM	Program_Control_Panel_Options
			WHERE 	Deleted = 0
					AND IsDominant = 1
					--AND Generic_Type = 'Distributor Trade/Shelter'
			<cfif arguments.orderCriteria eq 1>
			ORDER BY Generic_Type,Created_Type
			<cfelse>
			ORDER BY Created_Type
			</cfif>

		</cfquery>


		<cfreturn qGetAllTemplate />

	</cffunction>

	<cffunction name="getProfileForbidTemplate" output="false">

		<cfargument name="id" required="false" type="numeric" default="-1" />
		<cfargument name="forbidType" required="false" type="numeric" default="0" />
		<cfargument name="forbidAccessType" required="false" type="numeric" default="0" />
		<cfargument name="profileId" required="false" type="numeric" default="0" />

		<cfquery name="qGetProfileForbidTemplate" datasource="#application.datasource#">
			SELECT 	Profile_Forbidden_Template.*
			FROM 	Profile_Forbidden_Template
			WHERE 	Deleted = 0
					<cfif arguments.forbidType NEQ 0>
					AND Forbid_Type = <cfqueryparam value="#arguments.forbidType#" cfsqltype="CF_SQL_INTEGER">
					</cfif>
					<cfif arguments.forbidAccessType NEQ 0>
					AND Forbid_Access_Type = <cfqueryparam value="#arguments.forbidAccessType#" cfsqltype="CF_SQL_INTEGER">
					</cfif>
					<cfif arguments.id NEQ -1>
					AND Template_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
					</cfif>
					<cfif arguments.profileId NEQ 0>
					AND Profile_ID = <cfqueryparam value="#arguments.profileId#" cfsqltype="CF_SQL_INTEGER">
					</cfif>
		</cfquery>

		<cfreturn qGetProfileForbidTemplate>

	</cffunction>

	<cffunction name="getAllDiscountTypes" output="false">

		<cfargument name="id" required="true" type="numeric" />
		<cfargument name="allowList" required="false" default="" type="string" />

		<cfquery name="qGetAllDiscountTypes" datasource="#application.datasource#">
			SELECT 	Discount_Type_ID, Discount_Type_Desc
			FROM	Discount_Type
					INNER JOIN Program_Control_Panel_Options
					ON
					Program_Control_Panel_Options.Deleted = 0
					AND
					Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = #arguments.id#
					AND
					(
						(
							Discount_Type_ID = 1
							AND
							Program_Control_Panel_Options.Discount_Fixed_Prices = 1
						)
						OR
						(
							Discount_Type_ID = 2
							AND
							Program_Control_Panel_Options.Discount_Rebates = 1
						)
						OR
						(
							Discount_Type_ID = 3
							AND
							Program_Control_Panel_Options.Discount_Lump_Sums = 1
						)
						OR
						(
							Discount_Type_ID = 4
							AND
							Program_Control_Panel_Options.Discount_Growth = 1
						)
						OR
						(
							Discount_Type_ID = 5
							AND
							Program_Control_Panel_Options.Discount_Formula_Pricing = 1
						)
						OR
						(
							Discount_Type_ID = 8
							AND
							Program_Control_Panel_Options.Generic_Type = 'Distributor Off-Invoice'
						)
						OR
						(
							Discount_Type_ID = 10
							AND
							Program_Control_Panel_Options.Discount_BidRequest = 1
						)
					)

			WHERE 	Discount_Type.Deleted = 0
			<cfif arguments.allowList NEQ "">
			AND		Discount_Type.Discount_Type_ID IN (<cfqueryparam value="#arguments.allowList#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfif>
			ORDER BY Discount_Type_ID
		</cfquery>

		<cfreturn qGetAllDiscountTypes />

	</cffunction>

	<cffunction name="getComponentDiscountTypeList" output="false">

		<cfreturn "1,2,3,4,8,10" />

	</cffunction>

	<cffunction name="getAllComponentDiscountTypes" output="false">

		<cfargument name="templateId" required="true" type="numeric" />

		<cfreturn getAllDiscountTypes(arguments.templateId, getComponentDiscountTypeList()) />

	</cffunction>

	<cffunction name="getAllTemplateDiscountComponents" output="false" access="remote">

		<cfargument name="templateId" required="true" type="numeric" />
		<cfargument name="discountTypeList" required="true" type="string" />
		<cfargument name="returnSelected" required="false" type="numeric" default="1" />
		<cfargument name="componentId" required="false" type="numeric" default="0" />
		<cfargument name="templateIsDominant" required="false" type="numeric" default="0" />
		<cfargument name="fixedprice_freight" required="false" type="numeric" default="0" />
		<cfargument name="ConsiderFreightType" required="false" type="numeric" default="1" />
		<cfargument name="fixedPriceType" required="false" type="string" default="" />

		<cfquery name="qGetAllTemplateDiscountComponents" datasource="#application.datasource#">
			<!------ This is just so I can use union above next queries and don't need to know which one is first and which one is last ----->
			DECLARE @Tmp_All_Discount_Components table
			(
				Component_ID Int,
				Component_Name NVARCHAR(100),
				External_ID NVARCHAR(100),
				Discount_Type_ID Int,
				fixedType Int,
				Allowance_Code_ID Int,
				Active Bit,
				Greatest_Program_Value Bit
			)
			<cfloop list="#arguments.discountTypeList#" index="discountTypeId">
			<cfswitch expression="#discountTypeId#">
				<cfcase value="1"><!------ Fixed ----->
				INSERT INTO @Tmp_All_Discount_Components(Component_ID, Component_Name, External_ID, Discount_Type_ID, fixedType, Allowance_Code_ID, Active, Greatest_Program_Value)
				SELECT	Program_Fixed_Component_Name_ID Component_ID, Program_Fixed_Component_Name Component_Name, External_ID, #discountTypeId# Discount_Type_ID, Fixed_Component_Type, Allowance_Code_ID, Active, Greatest_Program_Value
				FROM	Program_Fixed_Component_Name
				WHERE	Program_Fixed_Component_Name.Deleted = 0
			<!---	<cfif ConsiderFreightType IS 1>
					<cfif arguments.fixedprice_freight EQ 1>
					and Program_Fixed_Component_Name.fixed_component_type = 3
					<cfelse>
					and Program_Fixed_Component_Name.fixed_component_type != 3
					</cfif>
				</cfif> --->
				<!--- check whether the template contains fixed price components which have "fixed price type" turned ON for Competitive data. These types are Deviated price (meets competition) and combination (blended) --->
				<cfif arguments.fixedPriceType eq 1>
					and Program_Fixed_Component_Name.fixed_price_type IN (1,3)
				</cfif>
				</cfcase>
				<cfcase value="2"><!------ Rebate ----->
				INSERT INTO @Tmp_All_Discount_Components(Component_ID, Component_Name, External_ID, Discount_Type_ID, fixedType, Allowance_Code_ID, Active)
				SELECT	Program_Rebates_Component_Name_ID Component_ID, Program_Rebates_Component_Name Component_Name, External_ID, #discountTypeId# Discount_Type_ID, 0, Allowance_Code_ID, Active
				FROM	Program_Rebates_Component_Name
				WHERE	Program_Rebates_Component_Name.Deleted = 0
				</cfcase>
				<cfcase value="3"><!------ Lump Sum ----->
				INSERT INTO @Tmp_All_Discount_Components(Component_ID, Component_Name, External_ID, Discount_Type_ID, fixedType, Allowance_Code_ID, Active)
				SELECT	Program_Lump_Sum_Name_ID Component_ID, Program_Lump_Sum_Name Component_Name, External_ID, #discountTypeId# Discount_Type_ID, 0, Allowance_Code_ID, Active
				FROM	Program_Lump_Sum_Name
				WHERE	Program_Lump_Sum_Name.Deleted = 0
				</cfcase>
				<cfcase value="4"><!------ Growth ----->
				INSERT INTO @Tmp_All_Discount_Components(Component_ID, Component_Name, External_ID, Discount_Type_ID, fixedType, Allowance_Code_ID, Active)
				SELECT	Program_Growth_Components_Name_ID Component_ID, Program_Growth_Components_Name Component_Name, External_ID, #discountTypeId# Discount_Type_ID, 0, Allowance_Code_ID, Active
				FROM	Program_Growth_Components_Name
				WHERE	Program_Growth_Components_Name.Deleted = 0
				</cfcase>
				<cfcase value="8"><!------ Off-Invoice ----->
				INSERT INTO @Tmp_All_Discount_Components(Component_ID, Component_Name, External_ID, Discount_Type_ID, fixedType, Allowance_Code_ID, Active)
				SELECT	Program_OffInvoice_Component_Name_ID Component_ID, Program_OffInvoice_Component_Name Component_Name, External_ID, #discountTypeId# Discount_Type_ID, 0, Allowance_Code_ID, Active
				FROM	Program_OffInvoice_Component_Name
				WHERE	Program_OffInvoice_Component_Name.Deleted = 0
				</cfcase>
				<cfcase value="10"><!------ Bid Request ----->
				INSERT INTO @Tmp_All_Discount_Components(Component_ID, Component_Name, External_ID, Discount_Type_ID, fixedType, Allowance_Code_ID, Active)
				SELECT	Program_BidRequest_Component_Name_ID Component_ID, Program_BidRequest_Component_Name Component_Name, External_ID, #discountTypeId# Discount_Type_ID, 0, Allowance_Code_ID, Active
				FROM	Program_BidRequest_Component_Name
				WHERE	Program_BidRequest_Component_Name.Deleted = 0
				</cfcase>
			</cfswitch>
			</cfloop>

			SELECT 	Program_Control_Panel_Options.Generic_Type,
					Program_Control_Panel_Options.ProgramControl_Panel_Options_ID Template_ID,
					Program_Control_Panel_Options.Created_Type,
          Program_Control_Panel_Options.First_Parent_ID,
          	Program_Control_Panel_Options.Default_Rebate_Component_Name_Id ,
          	Program_Control_Panel_Options.Default_Fixed_Component_Name_Id ,
					Tmp.*,
			CASE
			WHEN	Program_Template_Component.Program_Template_Component_ID IS NULL THEN 0
			ELSE	1
			END AS 	Component_Selected,
			Program_Template_Component.Program_Template_Component_ID,
			Program_Template_Component.Default_Paid_To_CF_Pages,
			Program_Template_Component.Default_Paid_To_Rates_Grid,
			Program_Control_Panel_Options.Fixed_Rebate_Grid_Option,
			Program_Control_Panel_Options.Discount_Rebates_Group_Level,
			Program_Control_Panel_Options.Single_Component_Per_Discount_Type,
			Program_Control_Panel_Options.Source,
			Program_Control_Panel_Options.Source_Required,
			Program_Control_Panel_Options.Source_Type,
			Program_Control_Panel_Options.Source_Type_Required,
			Program_Control_Panel_Options.Date_Source_Received,
			Program_Control_Panel_Options.Date_Source_Received_Required,
			Program_Control_Panel_Options.Won_By,
			Program_Control_Panel_Options.Won_By_Required,
			Program_Control_Panel_Options.Won_Rate,
			Program_Control_Panel_Options.Won_Rate_Required,
			Program_Control_Panel_Options.Won_UOM,
			Program_Control_Panel_Options.Won_UOM_Required
			FROM	Program_Control_Panel_Options

			LEFT JOIN @Tmp_All_Discount_Components Tmp
			ON		1=1
			<cfif arguments.componentId NEQ 0>
			AND		Tmp.Component_ID = <cfqueryparam value="#arguments.componentId#" cfsqltype="CF_SQL_INTEGER">
			</cfif>

			LEFT JOIN Program_Template_Component
			ON		Program_Template_Component.Deleted = 0
			AND		Program_Template_Component.Discount_Type_ID = Tmp.Discount_Type_ID
			AND		Program_Template_Component.Component_ID = Tmp.Component_ID
			AND		Program_Template_Component.Template_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
			WHERE	(ISNULL(Tmp.Active, 1) = 1 OR Program_Template_Component.Program_Template_Component_ID IS NOT NULL)
			AND		Program_Control_Panel_Options.Deleted = 0
			<cfif arguments.templateIsDominant NEQ 0>
			AND		Program_Control_Panel_Options.IsDominant = 1
			</cfif>
			<cfif arguments.returnSelected EQ 1>
			AND		Program_Template_Component.Program_Template_Component_ID IS NOT NULL
			</cfif>

			<cfif arguments.componentId NEQ 0><!------ only return applicable templates ----->
			AND
					(
						(
							#arguments.discountTypeList# = 1
							AND
							Program_Control_Panel_Options.Discount_Fixed_Prices = 1
						)
						OR
						(
							#arguments.discountTypeList# = 2
							AND
							Program_Control_Panel_Options.Discount_Rebates = 1
						)
						OR
						(
							#arguments.discountTypeList# = 3
							AND
							Program_Control_Panel_Options.Discount_Lump_Sums = 1
						)
						OR
						(
							#arguments.discountTypeList# = 4
							AND
							Program_Control_Panel_Options.Discount_Growth = 1
						)
						OR
						(
							#arguments.discountTypeList# = 5
							AND
							Program_Control_Panel_Options.Discount_Formula_Pricing = 1
						)
						OR
						(
							#arguments.discountTypeList# = 8
							AND
							Program_Control_Panel_Options.Generic_Type = 'Distributor Off-Invoice'
						)
						OR
						(
							#arguments.discountTypeList# = 10
							AND
							Program_Control_Panel_Options.Discount_BidRequest = 1
						)
					)
			</cfif>

			<cfif arguments.templateId NEQ 0>
			AND		Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = <cfqueryparam value="#arguments.templateId#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			ORDER BY Tmp.Discount_Type_ID, Tmp.Component_Name, Program_Control_Panel_Options.Generic_Type, Program_Control_Panel_Options.Created_Type, Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
		</cfquery>

		<cfreturn qGetAllTemplateDiscountComponents />

	</cffunction>

	<!--- get all the "Paid To" for a specific template component. --->
	<cffunction name="getAllTemplateDiscountComponentPaidTo" returntype="query" output="false">
		<cfargument name="Program_Template_component_ID" default="" type="string" />

		<cfquery name="qGetAllTemplateDiscountComponentPaidTo" datasource="#application.datasource#">
			SELECT Payment_Paid_To_ID
			FROM Program_Template_Component_And_Paid_To
			<cfif Program_Template_component_ID neq "">
			WHERE 	Program_Template_component_ID = <cfqueryparam value="#arguments.Program_Template_component_ID#" cfsqltype="CF_SQL_INTEGER">
			<cfelse>
			WHERE 1 = 0
			</cfif>
			AND deleted = 0
		</cfquery>

		<cfreturn qGetAllTemplateDiscountComponentPaidTo />
	</cffunction>

	<cffunction name="copyTemplateDiscountComponents" output="false">
		<cfargument name="fromId" required="false" default=0 type="numeric" />
		<cfargument name="toId" required="false" default=0 type="numeric" />

       <cfquery name="qDeleteExistingPaidTo" datasource="#application.datasource#">
            UPDATE Program_Template_Component_And_Paid_To
            SET Deleted = 1, Deleted_Date = getDate()
            WHERE Program_Template_Component_ID
            IN
            (
              SELECT Program_Template_Component_ID
              FROM Program_Template_Component
              WHERE               Deleted = 0
              AND Template_ID = <cfqueryparam value="#arguments.toId#" cfsqltype="CF_SQL_INTEGER">
            )
       </cfquery>

		<cfquery name="qDeleteExisting" datasource="#application.datasource#">
			UPDATE	Program_Template_Component
			SET		Deleted = 1
			WHERE	Deleted = 0
			AND		Template_ID = <cfqueryparam value="#arguments.toId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfquery name="qInsertNew" datasource="#application.datasource#">
			INSERT INTO Program_Template_Component(Template_ID, Discount_Type_ID, Component_ID
				,Default_Paid_To_CF_Pages, Default_Paid_To_Rates_Grid)
			SELECT DISTINCT #arguments.toId# Template_ID, Discount_Type_ID, Component_ID
				,Default_Paid_To_CF_Pages, Default_Paid_To_Rates_Grid
			FROM	Program_Template_Component
			WHERE	Deleted = 0
			AND		Template_ID = <cfqueryparam value="#arguments.fromId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfset copyTemplateDiscountComponentsPaidTo(arguments.fromId,arguments.toId)>
	</cffunction>

	<!--- Copy "Paid to" for the template components --->
     <cffunction name="copyTemplateDiscountComponentsPaidTo" output="false">
		    <cfargument name="fromId" required="false" default=0 type="numeric" />
		    <cfargument name="toId" required="false" default=0 type="numeric" />

		    <!--- "Program_Template_Component_ID" from the "Program_Template_Component" table gets
		    used as a key on the "Program_Template_Component_And_Paid_To" table. That is why a query,
		    (like the one below) )which can join on the old and new template is needed.
		    --->
		    <cfquery name="qInsertNew" datasource="#application.datasource#">
                   INSERT INTO Program_Template_Component_And_Paid_To(Program_Template_Component_ID,Payment_Paid_To_ID)
                   SELECT DISTINCT ptc1.Program_Template_Component_ID, ptcpt.Payment_Paid_To_ID
                   FROM  Program_Template_Component ptc
                   INNER JOIN Program_Template_Component ptc1
                   ON          ptc1.Template_ID = <cfqueryparam value="#arguments.toId#" cfsqltype="CF_SQL_INTEGER">
                   AND         ptc1.Discount_Type_ID = ptc.Discount_Type_ID
                   AND         ptc1.Component_ID = ptc.Component_ID
                   AND         ptc1.Deleted = 0
                   INNER JOIN Program_Template_Component_And_Paid_To ptcpt
                   ON          ptc.Program_Template_Component_ID = ptcpt.Program_Template_Component_ID
                   WHERE ptc.Deleted = 0
                   AND         ptcpt.Deleted = 0
                   AND         ptc.Template_ID = <cfqueryparam value="#arguments.fromId#" cfsqltype="CF_SQL_INTEGER">
		    </cfquery>

     </cffunction>

	<cffunction name="addAllTemplateDiscountComponents" output="false">

		<cfargument name="templateId" required="false" default=0 type="numeric" />

		<cfset discountTypeList = getComponentDiscountTypeList() />
		<cfloop list="#discountTypeList#" index="currentDiscountTypeId">
			<cfset qGetTemplateDiscountComponents = getAllTemplateDiscountComponents(arguments.templateId, currentDiscountTypeId, 0) />
			<cfset ComponentList = ValueList(qGetTemplateDiscountComponents.Component_ID) />
			<cfif ListLen(ComponentList) GT 0>
				<cfset saveTemplateDiscountComponents(arguments.templateId, currentDiscountTypeId, ComponentList) />
			</cfif>
		</cfloop>

	</cffunction>


	<cffunction name="saveTemplateDiscountComponents" output="false">

		<cfargument name="id" required="false" default=0 type="numeric" />
		<cfargument name="discountTypeId" required="false" default=0 type="numeric" />
		<cfargument name="ComponentSelectList" required="false" default=0 type="string"  />
		<cfargument name="ComponentPaidToDefaultCFPages" required="false" default="" type="string"  />
		<cfargument name="ComponentPaidToDefaultRatesGrid" required="false" default="" type="string"  />
		<cfargument name="structComponentPaidTo" required="false" default="#structNew()#" type="struct"  />

		<cftransaction>


		<!--- Delete all the "Paid To" for a template and discount type. --->
		<cfquery name="qDeleteExistingPaidTo" datasource="#application.datasource#">
			UPDATE	Program_Template_Component_And_Paid_To
			SET		Deleted = 1, Deleted_Date = getDate()
			WHERE	Program_Template_Component_id
			IN
			(
				SELECT 	Program_Template_Component_id
				FROM	Program_Template_Component
				WHERE		Deleted = 0
				AND		Template_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
				AND		Discount_Type_ID = <cfqueryparam value="#arguments.discountTypeId#" cfsqltype="CF_SQL_INTEGER">
			)
		</cfquery>

		<!--- Delete all the components for a template and discount type. --->
		<cfquery name="qDeleteExisting" datasource="#application.datasource#">
			UPDATE	Program_Template_Component
			SET		Deleted = 1
			WHERE	Deleted = 0
			AND		Template_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
			AND		Discount_Type_ID = <cfqueryparam value="#arguments.discountTypeId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<!--- loop through components --->
		<cfloop list="#arguments.ComponentSelectList#" index="componentId">

			<cfset DefaultPaidToCFPages = "">
			<cfloop list="#arguments.ComponentPaidToDefaultCFPages#" index="paidTo">
				<cfif Listgetat(paidTo,1,'_') eq componentId>
					<cfset DefaultPaidToCFPages = Listgetat(paidTo,2,'_')>
					<cfbreak>
				</cfif>
			</cfloop>

			<cfset DefaultPaidToRatesGrid = "">
			<cfloop list="#arguments.ComponentPaidToDefaultRatesGrid#" index="paidTo">
				<cfif Listgetat(paidTo,1,'_') eq componentId>
					<cfset DefaultPaidToRatesGrid = Listgetat(paidTo,2,'_')>
					<cfbreak>
				</cfif>
			</cfloop>

			<cfquery name="qInsertNew" datasource="#application.datasource#">
				INSERT INTO Program_Template_Component(Template_ID, Discount_Type_ID, Component_ID, Default_Paid_To_CF_Pages, Default_Paid_To_Rates_Grid)
				VALUES (
						<cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#arguments.discountTypeId#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#componentId#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#DefaultPaidToCFPages#" cfsqltype="CF_SQL_INTEGER" null="#iif((DefaultPaidToCFPages eq ""), de("yes"), de("no"))#">,
						<cfqueryparam value="#DefaultPaidToRatesGrid#" cfsqltype="CF_SQL_INTEGER" null="#iif((DefaultPaidToRatesGrid eq ""), de("yes"), de("no"))#">
					)
				SELECT Program_Template_Component_ID = @@IDENTITY
				SET NOCOUNT OFF
			</cfquery>

			<!--- Dev Note: WR 78635 - Check to see if it is a template which pays to "vendor only" --->
			<cfquery name="qCheckVendorPaidTo" datasource="#application.datasource#">
				SELECT 	Allow_Vendor_Only
				FROM	Program_Control_Panel_Options
				WHERE ProgramControl_Panel_Options_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>

			<cfif qCheckVendorPaidTo.Allow_Vendor_Only eq 0>
					<cfset i = 0>
					<!--- loop through the "paid to" struct. --->
					<cfloop collection="#structComponentPaidTo#" item="strOuterPaidTo">
					<cfset j = 0>
					<cfset i = i + 1>
							<cfloop collection="#structComponentPaidTo[i]#" item="strInnerPaidTo">
							<cfset j = j + 1>
								<cfif Listgetat(structComponentPaidTo[i][j],1,'_') eq componentId>
									<!--- Get "paid to" at the discount type and template combination.
									It is already inside a "component" loop and so actually the "paid to"
									is at a discount type, template and "paid to" level.
									--->
									<cfset PaidTo = Listgetat(structComponentPaidTo[i][j],2,'_')>

									<cfquery name="qInsertNewPaidTo" datasource="#application.datasource#">
										INSERT INTO Program_Template_Component_And_Paid_To(Program_Template_Component_ID,Payment_Paid_To_ID)
										VALUES (
												<cfqueryparam value="#qInsertNew.Program_Template_Component_ID#" cfsqltype="CF_SQL_INTEGER">,
												<cfqueryparam value="#PaidTo#" cfsqltype="CF_SQL_INTEGER">
											)
									</cfquery>
								</cfif>
							</cfloop>
						</cfloop>

				<cfelse>
						<!--- Dev Note: WR 78635 - If it is a template which pays to "vendor only", then insert "distributor" as the payee. --->
						<cfquery name="qInsertNewPaidTo" datasource="#application.datasource#">
							INSERT INTO Program_Template_Component_And_Paid_To(Program_Template_Component_ID,Payment_Paid_To_ID)
							VALUES (<cfqueryparam value="#qInsertNew.Program_Template_Component_ID#" cfsqltype="CF_SQL_INTEGER">,1)
						</cfquery>
				</cfif>

		</cfloop>
		</cftransaction>

	</cffunction>

	<cffunction name="saveDiscountComponentTemplates" output="false">

		<cfargument name="id" required="false" default=0 type="numeric" />
		<cfargument name="discountTypeId" required="false" default=0 type="numeric" />
		<cfargument name="TemplateSelectList" required="false" default=0 type="string"  />
		<cfargument name="TemplatePaidToDefaultCFPages" required="false" default="" type="string"  />
		<cfargument name="TemplatePaidToDefaultRatesGrid" required="false" default="" type="string"  />
		<cfargument name="structTemplatePaidTo" required="false" default="#structNew()#" type="struct"  />

		<!--- Delete all the "Paid To" for a component and discount type.--->
		<cfquery name="qDeleteExistingPaidTo" datasource="#application.datasource#">
			UPDATE	Program_Template_Component_And_Paid_To
			SET		Deleted = 1, Deleted_Date = getDate()
			WHERE	Program_Template_Component_id
			IN
			(
				SELECT 	Program_Template_Component_id
				FROM	Program_Template_Component
				WHERE		Deleted = 0
				AND		Component_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
				AND		Discount_Type_ID = <cfqueryparam value="#arguments.discountTypeId#" cfsqltype="CF_SQL_INTEGER">
			)
		</cfquery>

		<cfquery name="qDeleteExisting" datasource="#application.datasource#">
			UPDATE	Program_Template_Component
			SET		Deleted = 1
			WHERE	Deleted = 0
			AND		Component_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
			AND		Discount_Type_ID = <cfqueryparam value="#arguments.discountTypeId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfloop list="#arguments.TemplateSelectList#" index="templateId">

			<cfset DefaultPaidToCFPages = "">
			<cfloop list="#arguments.TemplatePaidToDefaultCFPages#" index="paidTo">
				<cfif Listgetat(paidTo,1,'_') eq templateId>
					<cfset DefaultPaidToCFPages = Listgetat(paidTo,2,'_')>
					<cfbreak>
				</cfif>
			</cfloop>

			<cfset DefaultPaidToRatesGrid = "">
			<cfloop list="#arguments.TemplatePaidToDefaultRatesGrid#" index="paidTo">
				<cfif Listgetat(paidTo,1,'_') eq templateId>
					<cfset DefaultPaidToRatesGrid = Listgetat(paidTo,2,'_')>
					<cfbreak>
				</cfif>
			</cfloop>

			<cfquery name="qInsertNew" datasource="#application.datasource#">
				INSERT INTO Program_Template_Component(Component_ID, Discount_Type_ID, Template_ID, Default_Paid_To_CF_Pages, Default_Paid_To_Rates_Grid)
				VALUES (
						<cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#arguments.discountTypeId#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#templateId#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#DefaultPaidToCFPages#" cfsqltype="CF_SQL_INTEGER" null="#iif((DefaultPaidToCFPages eq ""), de("yes"), de("no"))#">,
						<cfqueryparam value="#DefaultPaidToRatesGrid#" cfsqltype="CF_SQL_INTEGER" null="#iif((DefaultPaidToRatesGrid eq ""), de("yes"), de("no"))#">
					)
				SELECT Program_Template_Component_ID = @@IDENTITY
				SET NOCOUNT OFF
			</cfquery>


			<cfset i = 0>
			<!--- loop through the "paid to" struct. --->
			<cfloop collection="#structTemplatePaidTo#" item="strOuterPaidTo">
			<cfset j = 0>
			<cfset i = i + 1>
				<cfloop collection="#structTemplatePaidTo[i]#" item="strInnerPaidTo">
				<cfset j = j + 1>
					<cfif Listgetat(structTemplatePaidTo[i][j],1,'_') eq templateId>
						<!--- Get "paid to" at the discount type and component combination.
						It is already inside a "template" loop and so actually the "paid to"
						is at a discount type, template and "paid to" level.
						--->
						<cfset PaidTo = Listgetat(structTemplatePaidTo[i][j],2,'_')>

						<cfquery name="qInsertNewPaidTo" datasource="#application.datasource#">
							INSERT INTO Program_Template_Component_And_Paid_To(Program_Template_Component_ID,Payment_Paid_To_ID)
							VALUES (
									<cfqueryparam value="#qInsertNew.Program_Template_Component_ID#" cfsqltype="CF_SQL_INTEGER">,
									<cfqueryparam value="#PaidTo#" cfsqltype="CF_SQL_INTEGER">
								)
						</cfquery>
					</cfif>
				</cfloop>
			</cfloop>
		</cfloop>

	</cffunction>

	<cffunction name="getLumpSumTotal" output="false">

		<cfargument name="id" required="true" type="numeric" />
		<cfargument name="programId" required="false" type="numeric" default="0" />

		<cfset returnValue = 0>

		<cfif arguments.programId NEQ 0>
            <cfquery name="qGetLumpSumTotal" datasource="#application.datasource#">
                SELECT	ISNULL(SUM(ISNULL(CAST(Program_Lump_Sums.Lump_Sum_Amount AS Float), 0)), 0) As Total_Lump_Sum_Amount
                FROM	Contract_Main
                        INNER JOIN Program_Lump_Sums
                        ON
                        Program_Lump_Sums.Deleted = 0
                AND 	Program_Lump_Sums.Program_ID = Contract_Main.Contract_Main_ID
                WHERE	Contract_Main.ProgramType_ID = #arguments.id#
                <cfif arguments.programId NEQ 0>
                AND		Contract_Main.Contract_Main_ID = #arguments.programId#
                <cfelse>
                AND		Contract_Main.Contract_Status_Type_IDX > 3
                AND		Contract_Main.Deleted = 0
                </cfif>
            </cfquery>
			<cfset returnValue = qGetLumpSumTotal.Total_Lump_Sum_Amount />
		<cfelse>
            <cfquery name="qGetLumpSumTotalPerProgram" datasource="#application.datasource#">
                SELECT	CASE
                    WHEN ISNULL(SUM(ISNULL(CAST(Program_Lump_Sums.Lump_Sum_Amount AS Float), 0)), 0) >=
                    (
                    SELECT ISNULL(SUM(BB_Program_Lump_Sum_Distributor.Paid_Amount), 0)
                    FROM	BB_Program_Lump_Sum_Distributor
                    LEFT JOIN Billback
                    ON
                    BB_Program_Lump_Sum_Distributor.Billback_ID = Billback.Billback_ID
                    AND Billback.Billback_Status_ID >= 3
                    WHERE
                    BB_Program_Lump_Sum_Distributor.Deleted = 0
                    AND BB_Program_Lump_Sum_Distributor.Contract_Number = Contract_Main.Contract_Number
                    ) THEN ISNULL(SUM(ISNULL(CAST(Program_Lump_Sums.Lump_Sum_Amount AS Float), 0)), 0)
                    ELSE
                    (
                    SELECT ISNULL(SUM(BB_Program_Lump_Sum_Distributor.Paid_Amount), 0)
                    FROM	BB_Program_Lump_Sum_Distributor
                    LEFT JOIN Billback
                    ON
                    BB_Program_Lump_Sum_Distributor.Billback_ID = Billback.Billback_ID
                    AND Billback.Billback_Status_ID >= 3
                    WHERE
                    BB_Program_Lump_Sum_Distributor.Deleted = 0
                    AND BB_Program_Lump_Sum_Distributor.Contract_Number = Contract_Main.Contract_Number
                    )
                    END Total_Lump_Sum_Amount

                FROM	Contract_Main
                    INNER JOIN Program_Lump_Sums
                    ON
                    Program_Lump_Sums.Deleted = 0
                AND 	Program_Lump_Sums.Program_ID = Contract_Main.Contract_Main_ID
                WHERE	Contract_Main.ProgramType_ID = #arguments.id#

                AND	Contract_Main.Contract_Status_Type_IDX > 3
                AND	Contract_Main.Deleted = 0

                Group By Contract_Main.Contract_Number
            </cfquery>

        	<!--- D17526 [begin] (let's be sure we have SOME lump sum before we ask for more detail on it...) --->
			<cfif qGetLumpSumTotalPerProgram.recordCount AND isDefined("qGetLumpSumTotalPerProgram.Total_Lump_Sum_Amount") AND len(trim(qGetLumpSumTotalPerProgram.Total_Lump_Sum_Amount[1]))>
                <cfquery name="qGetLumpSumTotal" dbtype="query">
                    SELECT	SUM(Total_Lump_Sum_Amount) Total_Lump_Sum_Amount
                    FROM	qGetLumpSumTotalPerProgram
                </cfquery>
                <!--- D17526 [below moved inside of this if] --->
				<cfif qGetLumpSumTotal.recordCount>
					<cfset returnValue = returnValue + qGetLumpSumTotal.Total_Lump_Sum_Amount>
                </cfif>
            </cfif>
            <!--- D17526 [end] --->

		</cfif>

		<cfif arguments.programId EQ 0>

			<cfquery name="qGetTemplate" datasource="#application.datasource#">
				SELECT 	Created_Type, ProgramControl_Panel_Options_ID, ChildOf
				FROM	Program_Control_Panel_Options
				WHERE 	Deleted = 0
				AND		ProgramControl_Panel_Options_ID = #arguments.id#
			</cfquery>

			<cfif isNumeric(qGetTemplate.ChildOf) AND qGetTemplate.ChildOf NEQ 0>
				<cfset returnValue = returnValue + this.getLumpSumTotal(qGetTemplate.ChildOf)>
			</cfif>

		</cfif>

		<cfreturn returnValue>

	</cffunction>


	<cffunction name="getLatestLumpSumCap" output="false">

		<cfargument name="id" required="true" type="numeric" />

		<cfset returnValue = 0>

		<cfquery name="qGetTemplate" datasource="#application.datasource#">
			SELECT 	Program_Control_Panel_Options.IsDominant parentIsDominant,
					childTemplate.IsDominant chilsIsDominant,
					Program_Control_Panel_Options.Lump_Sum_Cap Parent_Lump_Sum_Cap,
					childTemplate.Lump_Sum_Cap Child_Lump_Sum_Cap,
					childTemplate.ProgramControl_Panel_Options_ID childId
			FROM	Program_Control_Panel_Options
					LEFT JOIN Program_Control_Panel_Options childTemplate
					ON
					childTemplate.ChildOf = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
			WHERE 	Program_Control_Panel_Options.Deleted = 0
			AND		Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = #arguments.id#
		</cfquery>

		<cfif qGetTemplate.chilsIsDominant EQ "1">
			<cfset returnValue = qGetTemplate.Child_Lump_Sum_Cap>
		<cfelseif qGetTemplate.parentIsDominant EQ "1">
			<cfset returnValue = qGetTemplate.Parent_Lump_Sum_Cap>
		<cfelseif isNumeric(qGetTemplate.childId)>
			<cfset returnValue = this.getLatestLumpSumCap(qGetTemplate.childId)>
		<cfelse>
			<cfset returnValue = qGetTemplate.Parent_Lump_Sum_Cap>
		</cfif>

		<cfreturn returnValue>

	</cffunction>

	<cffunction name="getLatestTemplateId" output="false">

		<cfargument name="id" required="true" type="numeric" />

		<cfset returnValue = arguments.id>

		<cfquery name="qGetTemplate" datasource="#application.datasource#">
			SELECT 	Program_Control_Panel_Options.IsDominant parentIsDominant,
					childTemplate.IsDominant chilsIsDominant,
					childTemplate.ProgramControl_Panel_Options_ID childId
			FROM	Program_Control_Panel_Options
					LEFT JOIN Program_Control_Panel_Options childTemplate
					ON
					childTemplate.ChildOf = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
			WHERE 	Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = #arguments.id#
		</cfquery>

		<cfif qGetTemplate.chilsIsDominant EQ "1">
			<cfset returnValue = qGetTemplate.childId>
		<cfelseif qGetTemplate.parentIsDominant>
			<cfset returnValue = arguments.id>
		<cfelseif isNumeric(qGetTemplate.childId)>
			<cfset returnValue = this.getLatestTemplateId(qGetTemplate.childId)>
		<cfelse>
			<cfset returnValue = arguments.id>
		</cfif>

		<cfreturn returnValue>

	</cffunction>


	<cffunction name="getThisTemplateIDList" output="false">
		<cfargument name="id" required="true" type="numeric" />

		<CFQUERY NAME="GetTemplateID" DATASOURCE="#Application.Datasource#">
			SELECT ProgramType_ID FROM Contract_Main WHERE Contract_Main_ID = #arguments.id#
		</CFQUERY>

		<CFSET ParentsList = this.getThisTemplateParentsID(GetTemplateID.ProgramType_ID)>
		<CFSET ChildrenList = this.getThisTemplateChildrenID(GetTemplateID.ProgramType_ID)>

		<CFSET returnValue = ParentsList>
		<CFSET returnValue = LISTAPPEND(returnValue,ChildrenList)>
		<CFIF LISTFIND(returnValue,"#GetTemplateID.ProgramType_ID#",",") EQ 0>
			<CFSET returnValue = LISTAPPEND(returnValue,GetTemplateID.ProgramType_ID)>
		</CFIF>

		<cfreturn returnValue>
	</cffunction>


	<cffunction name="getThisTemplateParentsID" output="false">
		<cfargument name="id" required="true" type="numeric" />
		<cfargument name="idList" required="false" type="string" default=""/>

		<cfset useLakebaseForgetParentID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForgetParentID>
	<cftry>
		<cfset getParentID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#arguments.id#",
				"select" = "childof parent"
			}), "childof parent"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetParentID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetParentID>
<CFQUERY NAME="getParentID" DATASOURCE="#Application.Datasource#">
			SELECT 	Program_Control_Panel_Options.ChildOf parent
			FROM	Program_Control_Panel_Options
			WHERE 	Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = #arguments.id#
		</CFQUERY>
</cfif>

		<CFIF getParentID.parent NEQ "">
			<CFSET arguments.idList = LISTAPPEND(arguments.idList,getParentID.parent)>
			<CFSET returnValue = getThisTemplateParentsID(getParentID.parent,arguments.idList)>
		<CFELSEIF getParentID.parent EQ "" AND arguments.idList NEQ "">
			<CFSET arguments.idList = arguments.idList>
			<cfset returnValue = arguments.idList>
		<CFELSEIF getParentID.parent EQ "" AND arguments.idList EQ "">
			<CFSET arguments.idList = id>
			<cfset returnValue = arguments.id>
		</CFIF>

		<cfreturn returnValue>
	</cffunction>

	<cffunction name="getThisTemplateChildrenID" output="false">
		<cfargument name="id" required="true" type="numeric" />
		<cfargument name="idList" required="false" type="string" default=""/>
		<cfset returnValue = "">

		<CFQUERY NAME="getChildID" DATASOURCE="#Application.Datasource#">
			SELECT		childTemplate.ProgramControl_Panel_Options_ID childId
			FROM		Program_Control_Panel_Options
			LEFT JOIN 	Program_Control_Panel_Options childTemplate ON childTemplate.ChildOf = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
			WHERE 		Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = #arguments.id#
		</CFQUERY>

		<CFIF getChildID.childId NEQ "">
			<CFSET arguments.idList = LISTAPPEND(arguments.idList,getChildID.childId)>
			<CFSET returnValue = getThisTemplateChildrenID(getChildID.childId,arguments.idList)>
		<CFELSEIF getChildID.childId EQ "" AND arguments.idList NEQ "">
			<CFSET arguments.idList = arguments.idList>
			<CFSET returnValue = arguments.idList>
		<CFELSEIF getChildID.childId EQ "" AND arguments.idList EQ "">
			<CFSET arguments.idList = id>
			<cfset returnValue = arguments.id>
		</CFIF>

		<cfreturn returnValue>
	</cffunction>

	<!---Dev Note: Kal - 15737: Gets the list of all templates created from the same first parent --->
	<cffunction name="getThisTemplateAllParentsID" output="false">
		<cfargument name="id" required="true" type="numeric" />

		<cfset var returnIDList = "" />

		<cfquery name="qGetThisTemplateAllParentsID" datasource="#application.datasource#">
			SELECT		PCP.Programcontrol_Panel_Options_ID
			FROM 		Program_Control_Panel_Options PCP_Latest
			INNER JOIN 	Program_Control_Panel_Options PCP ON PCP_Latest.First_Parent_ID = PCP.First_Parent_ID
			WHERE	 	PCP_Latest.Programcontrol_Panel_Options_ID = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
			AND 		PCP.Deleted = 0
			ORDER BY 	PCP.Programcontrol_Panel_Options_ID
		</cfquery>

		<cfset returnIDList = ValueList(qGetThisTemplateAllParentsID.Programcontrol_Panel_Options_ID) />
		<cfreturn returnIDList />

	</cffunction>

	<cffunction name="getPaidToOption" returntype="numeric" hint="Returns 0 - ANY, 1 - only Distributor, 2 - only Operator.">

		<cfargument name="contractMainId" type="numeric" required="true" />

		<!---set default return value--->
		<cfset rVal = 0 />

		<!---get the Generic Type based on the control panel options id--->
		<cfquery name="qGetGenericType" datasource="#application.datasource#">

			SELECT	Generic_Type
			FROM	Program_Control_Panel_Options
			WHERE	Deleted = 0
			AND		ProgramControl_Panel_Options_ID =
					(
						SELECT 	ProgramType_ID
						FROM	Contract_Main
						WHERE	Deleted = 0
						AND		Contract_Main_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.contractMainId#" />
					)

		</cfquery>

		<cfif qGetGenericType.RecordCount>

			<!---if it's Distributor Trade/Shelter--->
			<cfif trim(qGetGenericType.Generic_Type) eq "Distributor Trade/Shelter">
				<cfset rVal = 1 />
			<!---if it's Operator Direct or HQ Programs--->
			<cfelseif trim(qGetGenericType.Generic_Type) eq "Operator Direct or HQ Programs">
				<cfset rVal = 2 />
			<!---everything else--->
			<cfelse>
				<cfset rVal = 0 />
			</cfif>

		</cfif>

		<cfreturn rVal />

	</cffunction>

	<cffunction name="getTemplateAllowApprovalGroup" returntype="query">

		<cfargument name="templateId" type="numeric" required="true" />

		<cfquery name="qGetTemplateAllowApprovalGroup" datasource="#application.datasource#">
			SELECT	*
			FROM	Template_Allow_Approval_Group
			WHERE	Program_Type_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.templateId#" />
			AND		Deleted = 0
		</cfquery>

		<cfreturn qGetTemplateAllowApprovalGroup />

	</cffunction>

	<cffunction name="getTemplateAllowApprovalGroupList" returntype="string">

		<cfargument name="templateId" type="numeric" required="true" />

		<cfset qGetTemplateAllowApprovalGroup = getTemplateAllowApprovalGroup(arguments.templateId) />

		<cfreturn ValueList(qGetTemplateAllowApprovalGroup.Group_ID) />

	</cffunction>

	<cffunction name="getTemplateAllowProductGroupLevel" returntype="query">

		<cfargument name="templateId" type="numeric" required="true" />

		<!--- <cfquery name="qGetTemplateAllowProductGroupLevel" datasource="#application.datasource#">
			SELECT	*
			FROM	Template_Allow_Product_Group_Level
			WHERE	Template_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.templateId#" />
			AND		Deleted = 0
		</cfquery>		 --->
    <cfquery name="GetTemplateInfo" datasource="#application.datasource#">
		  SELECT First_parent_ID
      FROM Program_Control_Panel_Options
      WHERE ProgramControl_Panel_Options_ID =  <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.templateId#" />
    </cfquery>


    <cfquery name="qGetTemplateAllowProductGroupLevel" datasource="#application.datasource#">
		  SELECT * FROM Group_Template
      WHERE Template_ID = #GetTemplateInfo.First_parent_ID# AND
      Deleted = 0 AND Active = 1 AND Allow_In_Group_Search = 1
		</cfquery>

		<cfreturn qGetTemplateAllowProductGroupLevel />

	</cffunction>

	<cffunction name="getTemplateAllowProductGroupLevelList" returntype="string">

		<cfargument name="templateId" type="numeric" required="true" />

		<cfset qGetTemplateAllowProductGroupLevel = getTemplateAllowProductGroupLevel(arguments.templateId) />

		<cfreturn ValueList(qGetTemplateAllowProductGroupLevel.Group_Level_ID) />

	</cffunction>

	<cffunction name="saveTemplateAllowProductGroupLevelFromList" returntype="void">

		<cfargument name="templateId" type="numeric" required="true" />
		<cfargument name="groupLevelList" type="string" required="true" />

		<cftransaction action="BEGIN">

			<cftry>

				<cfquery name="qDeleteTemplateAllowProductGroupLevels" datasource="#application.datasource#">
					UPDATE	Template_Allow_Product_Group_Level
					SET		Deleted = 1
					WHERE	Deleted = 0
					AND		Template_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.templateId#" />
				</cfquery>

				<cfloop list="#arguments.groupLevelList#" index="currentGroupLevelID">
					<cfquery name="qInsertTemplateAllowProductGroupLevel" datasource="#application.datasource#">
						INSERT INTO Template_Allow_Product_Group_Level (Template_ID, Group_Level_ID)
						VALUES (<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.templateId#" />,
								<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#currentGroupLevelID#" />)
					</cfquery>
				</cfloop>

				<cftransaction action="COMMIT"/>

				<cfcatch type="any">
					<cftransaction action="ROLLBACK"/>
					<cfrethrow />
				</cfcatch>

			</cftry>

		</cftransaction>

	</cffunction>

		<!--- Dev Note: GV - D8828 : Payment Paid To at Template --->
	<cffunction name="GetPaymentPaidToTypes" output="false" returntype="query">
		<cfargument name="TemplateID" type="numeric" required="true"  />
		<cfargument name="discountTypeID" type="numeric" required="true" />
		<cfargument name="componentNameID" type="Numeric" required="true" />
		<cfargument name="GrowthAutoPay" type="numeric" required="false" default="0"  /> <!--- D35731 Growth Auto Pay --->
		<cfargument name="Allow_Broker_Payee" type="numeric" required="false" default="0"  /> <!--- Lump sum componenst can override template setting and add Broker --->

	<cfquery name="local.qGetPaymentPaidToTypes" datasource="#application.datasource#">
		SELECT 	Payment_Paid_To_Types.Payment_Paid_To_Type_Identifier, Payment_Paid_To_Types.Payment_Paid_To_Type_Name, Payment_Paid_To_Types.Payment_Paid_To_ID
		<cfif arguments.componentNameID GT 0>
		,Program_Template_Component.Default_Paid_To_CF_Pages, ISNULL(Program_Template_Component.Default_Paid_To_Rates_Grid,0) AS Default_Paid_To_Rates_Grid
		<cfelse>
		,'' As Default_Paid_To_CF_Pages, 0 As Default_Paid_To_Rates_Grid
		</cfif>

		FROM 	Payment_Paid_To_Types
		INNER JOIN Payment_Paid_To_Template_Mapping
			ON 		Payment_Paid_To_Types.Payment_Paid_To_ID = Payment_Paid_To_Template_Mapping.Payment_Paid_To_ID
		AND 	Payment_Paid_To_Template_Mapping.Deleted = <cfqueryparam value="0">

		<!--- get the paidto's for a template, discount type, and component level combination. --->
		<cfif arguments.componentNameID GT 0>
		INNER JOIN  Program_Template_Component
			ON Program_Template_Component.Template_ID = Payment_Paid_To_Template_Mapping.Template_ID
		AND Program_Template_Component.Deleted = <cfqueryparam value="0">
		INNER JOIN  Program_Template_Component_And_Paid_To
			ON Program_Template_Component_And_Paid_To.Program_Template_Component_ID = Program_Template_Component.Program_Template_Component_ID
		AND Program_Template_Component_And_Paid_To.Deleted = <cfqueryparam value="0">
		</cfif>

		WHERE 	Payment_Paid_To_Types.Deleted = <cfqueryparam value="0">

		<!--- get the paidto's for a template, discount type, and component level combination. --->
		<cfif arguments.componentNameID GT 0>
		AND Payment_Paid_To_Template_Mapping.Template_ID = <cfqueryparam value='#arguments.TemplateID#'>
		AND Program_Template_Component.Discount_Type_ID = <cfqueryparam value='#arguments.discountTypeID#'>
		AND Program_Template_Component.Component_ID = <cfqueryparam value='#arguments.componentNameID#'>
		AND Payment_Paid_To_Types.Payment_Paid_To_Id = Program_Template_Component_And_Paid_To.Payment_Paid_To_Id
		<cfelse>
		AND 	Payment_Paid_To_Template_Mapping.Template_ID = <cfqueryparam value='#arguments.TemplateID#'>
		</cfif>
		<!--- D35731 Growth Auto Pay START--->
		<cfif arguments.GrowthAutoPay>
		AND 	Payment_Paid_To_Types.Payment_Paid_To_Type_Identifier = <cfqueryparam value='D'>
		</cfif>
		<cfif arguments.Allow_Broker_Payee> <!--- INCLUDE BROKER IN RESULTS --->
			UNION SELECT Payment_Paid_To_Types.Payment_Paid_To_Type_Identifier, Payment_Paid_To_Types.Payment_Paid_To_Type_Name, Payment_Paid_To_Types.Payment_Paid_To_ID
			             ,'' As Default_Paid_To_CF_Pages, 0 As Default_Paid_To_Rates_Grid
			FROM 	Payment_Paid_To_Types WHERE Payment_Paid_To_ID = <cfqueryparam value="3">
		</cfif>
		<!--- D35731 Growth Auto Pay END--->
		ORDER BY Payment_Paid_To_Types.Payment_Paid_To_ID
	</cfquery>
	<cfreturn local.qGetPaymentPaidToTypes />
	</cffunction>


	<cffunction name="getPaymentPaidToTypeDesc" output="true" returntype="string">
		<cfargument name="paidToTypeIdentifier" required="false" type="string" default="" />
		<cfargument name="paidToID" required="false" type="numeric" default="0" />
		<cfargument name="paidToDesc" required="true" type="string" />

		<cfset var returnDesc = arguments.paidToDesc />

		<cfif arguments.paidToTypeIdentifier neq "">
			<cfswitch expression="#arguments.paidToTypeIdentifier#">
				<cfcase value="D">
					<cfset returnDesc = application.returned_customer_setting.distributor_label_singular />
				</cfcase>
				<cfcase value="O">
					<cfset returnDesc = application.returned_customer_setting.operator_label_singular />
				</cfcase>
				<cfcase value="B">
					<cfset returnDesc = application.returned_customer_setting.broker_label_singular />
				</cfcase>
				<cfcase value="DO">
					<cfset returnDesc = "#application.returned_customer_setting.distributor_label_singular# & #application.returned_customer_setting.operator_label_singular#" />
				</cfcase>
			</cfswitch>
		<cfelse>
			<cfswitch expression="#arguments.paidToID#">
				<cfcase value="1">
					<cfset returnDesc = application.returned_customer_setting.distributor_label_singular />
				</cfcase>
				<cfcase value="2">
					<cfset returnDesc = application.returned_customer_setting.operator_label_singular />
				</cfcase>
				<cfcase value="3">
					<cfset returnDesc = application.returned_customer_setting.broker_label_singular />
				</cfcase>
				<cfcase value="4">
					<cfset returnDesc = "#application.returned_customer_setting.distributor_label_singular# & #application.returned_customer_setting.operator_label_singular#" />
				</cfcase>
			</cfswitch>
		</cfif>

		<cfreturn returnDesc />
	</cffunction>

	<!--- Dev Note: KAL - D7952 : Lock/Unlock Template --->
		<cffunction name="getLocked" output="true" returntype="query">
			<cfargument name="TemplateID" required="true" type="numeric" />
			<cfset useLakebaseForqGetLocked = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForqGetLocked>
	<cftry>
		<cfset qGetLocked = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#arguments.TemplateID#",
				"select" = "programcontrol_panel_options_id,is_locked,locked_by,locked_time"
			}), "programcontrol_panel_options_id,is_locked,locked_by,locked_time"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetLocked = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetLocked>
<cfquery name="qGetLocked" datasource="#application.datasource#">
				Select 	ProgramControl_Panel_Options_ID, IS_Locked, Locked_By, Locked_Time
					FROM	Program_Control_Panel_Options
					WHERE	ProgramControl_Panel_Options_ID = '#arguments.TemplateID#'
			</cfquery>
</cfif>
			<cfreturn qGetLocked />
		</cffunction>

		<cffunction name="ReleaseLocks" output="false">
			<cfargument name="Current_User_ID" type="string" required="true" />
			<cfargument name="TemplateID" required="false" type="numeric" default="0" />

			<cfquery name="qReleaseLocks" datasource="#application.datasource#">
				UPDATE Program_Control_Panel_Options
					SET		IS_Locked = 0,
							Locked_By = null,
							Locked_Time = null
					WHERE	IS_Locked = 1
					AND		Locked_By = '#arguments.Current_User_ID#'
					AND 	Deleted = 0
					<cfif isdefined("TemplateID") and TemplateID NEQ 0>
					AND		ProgramControl_Panel_Options_ID = #arguments.TemplateID#
					</cfif>
			</cfquery>
		</cffunction>

		<cffunction name="LockTemplate" output="false">
			<cfargument name="TemplateID" required="true" type="numeric" />
			<cfargument name="Current_User_ID" type="string" required="true" />

			<cfquery name="qLockTemplate" datasource="#application.datasource#">
				UPDATE Program_Control_Panel_Options
					SET		IS_Locked = 1,
							Locked_By = '#arguments.Current_User_ID#',
							Locked_Time = getDate()
					WHERE	ProgramControl_Panel_Options_ID = '#arguments.TemplateID#'
					AND		Deleted = 0
			</cfquery>
		</cffunction>

		<cffunction name="GetNewTemplate" output="false">
			<cfargument name="TemplateID" required="true" type="numeric" />

			<cfset useLakebaseForqGetNewTemplate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForqGetNewTemplate>
	<cftry>
		<cfset qGetNewTemplate = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"childof" = "eq.#arguments.TemplateID#",
				"deleted" = "eq.0",
				"select" = "programcontrol_panel_options_id"
			}), "programcontrol_panel_options_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetNewTemplate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetNewTemplate>
<cfquery name="qGetNewTemplate" datasource="#application.datasource#">
				SELECT 	ProgramControl_Panel_Options_ID
					FROM 	Program_Control_Panel_Options
					WHERE	ChildOF = '#arguments.TemplateID#'
					AND		Deleted = 0
			</cfquery>
</cfif>

			<cfset returnValue = qGetNewTemplate.ProgramControl_Panel_Options_ID>
			<cfreturn returnValue />

		</cffunction>

		<cffunction name="GetLockerInfo" output="false">
			<cfargument name="Locker_User_ID" type="string" required="true" />
				<!--- if it is locked : Getting the name of the person Locked by --->
				<cfquery name="Locked_User_Info" datasource="#application.datasource#">
					Select Name_First, Name_Last
						From _USERS
						Where User_ID = <cfqueryparam  cfsqltype="CF_SQL_VARCHAR"  value="#arguments.Locker_User_ID#">
				</cfquery>

			<cfset returnValue = "#Locked_User_Info.Name_First#" & " " & "#Locked_User_Info.Name_Last#" />
			<cfreturn returnValue />

		</cffunction>
	<!---  Dev Note: KAL - D7952 : Lock/Unlock Template --->


	<cffunction name="saveLetters" output="false">
		<cfargument name="templatesIDList" required="true" type="String"/>
		<cfargument name="formScope" required="true" type="struct" />

			<cfquery name="updateletters" datasource="#application.datasource#">
				update Program_Control_Panel_Options
				set operator_letters_required = #Evaluate("arguments.formScope.Operator_Letters")#,
				distributor_letters_required =#Evaluate("arguments.formScope.Distributor_Letters")#,
				Distributor_Fixed_Pricing = #Evaluate("arguments.formScope.Distributor_Fixed_Pricing")#,
				Distributor_Rebate = #Evaluate("arguments.formScope.Distributor_Rebate")#,
				Distributor_Lumpsum = #Evaluate("arguments.formScope.Distributor_Lumpsum")# ,
				Distributor_Growth = #Evaluate("arguments.formScope.Distributor_Growth")# ,
				operator_Fixed_Pricing = #Evaluate("arguments.formScope.operator_Fixed_Pricing")#,
				operator_Rebate = #Evaluate("arguments.formScope.operator_Rebate")#,
				operator_Lumpsum = #Evaluate("arguments.formScope.operator_Lumpsum")#,
				operator_Growth = #Evaluate("arguments.formScope.operator_Growth")#,
				Operator_paysto_opr = #Evaluate("arguments.formScope.Operator_paysto_opr")#,
				Operator_paysto_dis = #Evaluate("arguments.formScope.Operator_paysto_dis")#,
				Distributor_paysto_opr = #Evaluate("arguments.formScope.Distributor_paysto_opr")#,
				Distributor_paysto_dis = #Evaluate("arguments.formScope.Distributor_paysto_dis")#,
				Distributor_Bid_Request = #Evaluate("arguments.formScope.Distributor_Bid_Request")# ,
				Operator_Bid_Request = #Evaluate("arguments.formScope.Operator_Bid_Request")#,
				include_freight_summary = #Evaluate("arguments.formScope.include_freight_summary")#,
				freight_uom = #Evaluate("arguments.formScope.freight_uom")#,
				Pre_Defined_Page_Break = #Evaluate("arguments.formScope.Pre_Defined_Page_Break")#,
				Distributor_UOM = #Evaluate("arguments.formScope.Distributor_UOM")#,
				Operator_UOM = #Evaluate("arguments.formScope.Operator_UOM")#,
				Distributor_Discount_Type = #Evaluate("arguments.formScope.Distributor_Discount_Type")#,
				Operator_Discount_Type = #Evaluate("arguments.formScope.Operator_Discount_Type")#,
				Distributor_Component_Name = #Evaluate("arguments.formScope.Distributor_Component_Name")#,
				Operator_Component_Name = #Evaluate("arguments.formScope.Operator_Component_Name")#,
				Distributor_Claim_Mechanism = #Evaluate("arguments.formScope.Distributor_Claim_Mechanism")#,
				Operator_Claim_Mechanism = #Evaluate("arguments.formScope.Operator_Claim_Mechanism")#,
				Distributor_Payable_To = #Evaluate("arguments.formScope.Distributor_Payable_To")#,
				Operator_Payable_To = #Evaluate("arguments.formScope.Operator_Payable_To")#,
				Distributor_Pricing_Type = #Evaluate("arguments.formScope.Distributor_Pricing_Type")#,
				Operator_Pricing_Type = #Evaluate("arguments.formScope.Operator_Pricing_Type")#,
				Distributor_Payment_Frequency = #Evaluate("arguments.formScope.Distributor_Payment_Frequency")#,
				Operator_Payment_Frequency = #Evaluate("arguments.formScope.Operator_Payment_Frequency")#,
				Distributor_GTIN = #Evaluate("arguments.formScope.Distributor_GTIN")#,
				Operator_GTIN = #Evaluate("arguments.formScope.Operator_GTIN")#,
				Distributor_Product_Attribute_1 = #Evaluate("arguments.formScope.Distributor_Product_Attribute_1")#,
				Operator_Product_Attribute_1 = #Evaluate("arguments.formScope.Operator_Product_Attribute_1")#
				,Email_Letters_On_Approval = #Evaluate("arguments.formScope.Email_Letters_On_Approval")#          <!---25704--->
				,Generate_Letters_On_Approval = #Evaluate("arguments.formScope.Generate_Letters_On_Approval")#
				,Distributor_Price_Brackets =#Evaluate("arguments.formScope.Distributor_Price_Brackets")#
				,Operator_Price_Brackets =#Evaluate("arguments.formScope.Operator_Price_Brackets")#
				,Distributor_Open_Date =#Evaluate("arguments.formScope.Distributor_Open_Date")#
				,Operator_Open_Date =#Evaluate("arguments.formScope.Operator_Open_Date")#
				,Distributor_Date_Needed =#Evaluate("arguments.formScope.Distributor_Date_Needed")#
				,Operator_Date_Needed =#Evaluate("arguments.formScope.Operator_Date_Needed")#
				,Distributor_Expected_Date =#Evaluate("arguments.formScope.Distributor_Expected_Date")#
				,Operator_Expected_Date =#Evaluate("arguments.formScope.Operator_Expected_Date")#
				,Distributor_Est_Value_Volume =#Evaluate("arguments.formScope.Distributor_Est_Value_Volume")#
				,Operator_Est_Value_Volume =#Evaluate("arguments.formScope.Operator_Est_Value_Volume")#
				,Distributor_Dist_Product_Codes =#Evaluate("arguments.formScope.Distributor_Dist_Product_Codes")#
				,Distributor_Customer_Acceptance_Block =#Evaluate("arguments.formScope.Distributor_Customer_Acceptance_Block")#
				,Operator_Customer_Acceptance_Block =#Evaluate("arguments.formScope.Operator_Customer_Acceptance_Block")#
				,Distributor_Line =#Evaluate("arguments.formScope.Distributor_Line")#
				,Operator_Line =#Evaluate("arguments.formScope.Operator_Line")#
				,Distributor_Notes =#Evaluate("arguments.formScope.Distributor_Notes")#
				,Operator_Notes =#Evaluate("arguments.formScope.Operator_Notes")#
				,Letters_Accepted_By = '#Evaluate("arguments.formScope.Letters_Accepted_By")#'<!---D36100 --->
				,Operator_Fixed_Pricing_Default = '#Evaluate("arguments.formScope.Operator_Fixed_Pricing_Default")#'
				,Operator_Rebate_Default = '#Evaluate("arguments.formScope.Operator_Rebate_Default")#'
				,Operator_Lumpsum_Default = '#Evaluate("arguments.formScope.Operator_Lumpsum_Default")#'
				,Operator_Bid_Request_Default = '#Evaluate("arguments.formScope.Operator_Bid_Request_Default")#'
				,Distributor_Fixed_Pricing_Default = '#Evaluate("arguments.formScope.Distributor_Fixed_Pricing_Default")#'
				,Distributor_Rebate_Default = '#Evaluate("arguments.formScope.Distributor_Rebate_Default")#'
				,Distributor_Lumpsum_Default = '#Evaluate("arguments.formScope.Distributor_Lumpsum_Default")#'
				,Distributor_Bid_Request_Default = '#Evaluate("arguments.formScope.Distributor_Bid_Request_Default")#'
				,Operator_Rate_Change = '#Evaluate("arguments.formScope.Operator_Rate_Change")#'
				,Distributor_Rate_Change = '#Evaluate("arguments.formScope.Distributor_Rate_Change")#'
				,Distributor_Display_Product_Groups = '#Evaluate("arguments.formScope.Distributor_Display_Product_Groups")#'
				,Operator_Display_Product_Groups = '#Evaluate("arguments.formScope.Operator_Display_Product_Groups")#'
				,Distributor_show_volume_summary = '#Evaluate("arguments.formScope.Distributor_show_volume_summary")#'
				,Operator_show_volume_summary = '#Evaluate("arguments.formScope.Operator_show_volume_summary")#'
				,Distributor_Product_Net_Weight = '#Evaluate("arguments.formScope.Distributor_Product_Net_Weight")#'
				,Operator_Product_Net_Weight = '#Evaluate("arguments.formScope.Operator_Product_Net_Weight")#'
				,Distributor_Broker_Number = '#Evaluate("arguments.formScope.Distributor_Broker_Number")#'
				,Operator_Broker_Number = '#Evaluate("arguments.formScope.Operator_Broker_Number")#'
				,Distributor_UPC = '#Evaluate("arguments.formScope.Distributor_UPC")#'
				,Operator_UPC = '#Evaluate("arguments.formScope.Operator_UPC")#'
				,Distributor_Approval_Date = '#Evaluate("arguments.formScope.Distributor_Approval_Date")#'
				,Operator_Approval_Date = '#Evaluate("arguments.formScope.Operator_Approval_Date")#'
				,Distributor_Generate_Excel_File_Product_Group_Members = '#Evaluate("arguments.formScope.Distributor_Generate_Excel_File_Product_Group_Members")#'
				,Operator_Generate_Excel_File_Product_Group_Members = '#Evaluate("arguments.formScope.Operator_Generate_Excel_File_Product_Group_Members")#'
				where ProgramControl_Panel_Options_ID in (#templatesIDList#)
				<!--- Dont use queryparam in the above query as templatesIDList is a list --->
			</cfquery>
	</cffunction>

	<cffunction name="getsavedLetters" output="false">
		<cfargument name="templateId" required="true" type="numeric" />
			<cfset useLakebaseForqgetsavedletters = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForqgetsavedletters>
	<cftry>
		<cfset qgetsavedletters = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#arguments.templateId#",
				"select" = "operator_letters_required,distributor_letters_required,distributor_fixed_pricing,distributor_rebate,distributor_lumpsum,distributor_growth,operator_fixed_pricing,operator_rebate,operator_lumpsum,operator_growth,distributor_paysto_opr,distributor_paysto_dis,operator_paysto_opr,operator_paysto_dis,operator_bid_request,distributor_bid_request,include_freight_summary,freight_uom,pre_defined_page_break,distributor_uom,operator_uom,distributor_discount_type,operator_discount_type,distributor_component_name,operator_component_name,distributor_claim_mechanism,operator_claim_mechanism,distributor_payable_to,operator_payable_to,distributor_pricing_type,operator_pricing_type,distributor_payment_frequency,operator_payment_frequency,distributor_gtin,operator_gtin,distributor_product_attribute_1,operator_product_attribute_1,email_letters_on_approval,generate_letters_on_approval,distributor_price_brackets,operator_price_brackets,distributor_open_date,operator_open_date,distributor_date_needed,operator_date_needed,distributor_expected_date,operator_expected_date,distributor_est_value_volume,operator_est_value_volume,distributor_dist_product_codes,distributor_customer_acceptance_block,operator_customer_acceptance_block,distributor_line,operator_line,distributor_notes,operator_notes,letters_accepted_by,operator_fixed_pricing_default,operator_rebate_default,operator_lumpsum_default,operator_bid_request_default,distributor_fixed_pricing_default,distributor_rebate_default,distributor_lumpsum_default,distributor_bid_request_default,operator_rate_change,distributor_rate_change,distributor_display_product_groups,operator_display_product_groups,distributor_show_volume_summary,operator_show_volume_summary,distributor_product_net_weight,operator_product_net_weight,distributor_broker_number,operator_broker_number,distributor_upc,operator_upc,operator_approval_date,distributor_approval_date,operator_generate_excel_file_product_group_members,distributor_generate_excel_file_product_group_members"
			}), "operator_letters_required,distributor_letters_required,distributor_fixed_pricing,distributor_rebate,distributor_lumpsum,distributor_growth,operator_fixed_pricing,operator_rebate,operator_lumpsum,operator_growth,distributor_paysto_opr,distributor_paysto_dis,operator_paysto_opr,operator_paysto_dis,operator_bid_request,distributor_bid_request,include_freight_summary,freight_uom,pre_defined_page_break,distributor_uom,operator_uom,distributor_discount_type,operator_discount_type,distributor_component_name,operator_component_name,distributor_claim_mechanism,operator_claim_mechanism,distributor_payable_to,operator_payable_to,distributor_pricing_type,operator_pricing_type,distributor_payment_frequency,operator_payment_frequency,distributor_gtin,operator_gtin,distributor_product_attribute_1,operator_product_attribute_1,email_letters_on_approval,generate_letters_on_approval,distributor_price_brackets,operator_price_brackets,distributor_open_date,operator_open_date,distributor_date_needed,operator_date_needed,distributor_expected_date,operator_expected_date,distributor_est_value_volume,operator_est_value_volume,distributor_dist_product_codes,distributor_customer_acceptance_block,operator_customer_acceptance_block,distributor_line,operator_line,distributor_notes,operator_notes,letters_accepted_by,operator_fixed_pricing_default,operator_rebate_default,operator_lumpsum_default,operator_bid_request_default,distributor_fixed_pricing_default,distributor_rebate_default,distributor_lumpsum_default,distributor_bid_request_default,operator_rate_change,distributor_rate_change,distributor_display_product_groups,operator_display_product_groups,distributor_show_volume_summary,operator_show_volume_summary,distributor_product_net_weight,operator_product_net_weight,distributor_broker_number,operator_broker_number,distributor_upc,operator_upc,operator_approval_date,distributor_approval_date,operator_generate_excel_file_product_group_members,distributor_generate_excel_file_product_group_members"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetsavedletters = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetsavedletters>
<cfquery name="qgetsavedletters" datasource="#application.datasource#">
				select operator_letters_required,distributor_letters_required,
				Distributor_Fixed_Pricing,Distributor_Rebate,Distributor_Lumpsum,Distributor_Growth,
				operator_Fixed_Pricing,operator_Rebate,operator_Lumpsum,operator_Growth,
				Distributor_paysto_opr,Distributor_paysto_dis,Operator_paysto_opr,
				Operator_paysto_dis,Operator_Bid_Request,Distributor_Bid_Request,include_freight_summary,freight_uom,
				Pre_Defined_Page_Break,
				Distributor_UOM,
				Operator_UOM,
				Distributor_Discount_Type,
				Operator_Discount_Type,
				Distributor_Component_Name,
				Operator_Component_Name,
				Distributor_Claim_Mechanism,
				Operator_Claim_Mechanism,
				Distributor_Payable_To,
				Operator_Payable_To,
				Distributor_Pricing_Type,
				Operator_Pricing_Type,
				Distributor_Payment_Frequency,
				Operator_Payment_Frequency,
				Distributor_GTIN,
				Operator_GTIN,
				Distributor_Product_Attribute_1,
				Operator_Product_Attribute_1
				,Email_Letters_On_Approval          <!---25704--->
				,Generate_Letters_On_Approval
				,Distributor_Price_Brackets
				,Operator_Price_Brackets
				,Distributor_Open_Date
				,Operator_Open_Date
				,Distributor_Date_Needed
				,Operator_Date_Needed
				,Distributor_Expected_Date
				,Operator_Expected_Date
				,Distributor_Est_Value_Volume
				,Operator_Est_Value_Volume
				,Distributor_Dist_Product_Codes
				,Distributor_Customer_Acceptance_Block
				,Operator_Customer_Acceptance_Block
				,Distributor_Line
				,Operator_Line
				,Distributor_Notes
				,Operator_Notes
				,Letters_Accepted_By <!---D36100 --->
				,Operator_Fixed_Pricing_Default
				,Operator_Rebate_Default
				,Operator_Lumpsum_Default
				,Operator_Bid_Request_Default
				,Distributor_Fixed_Pricing_Default
				,Distributor_Rebate_Default
				,Distributor_Lumpsum_Default
				,Distributor_Bid_Request_Default
				,Operator_Rate_Change
				,Distributor_Rate_Change
				,Distributor_Display_Product_Groups
				,Operator_Display_Product_Groups
				,Distributor_show_volume_summary
				,Operator_show_volume_summary
				,Distributor_Product_Net_Weight
				,Operator_Product_Net_Weight
				,Distributor_Broker_Number
				,Operator_Broker_Number
				,Distributor_UPC
				,Operator_UPC
				,Operator_Approval_Date
				,Distributor_Approval_Date
				,Operator_Generate_Excel_File_Product_Group_Members
				,Distributor_Generate_Excel_File_Product_Group_Members
				from  Program_Control_Panel_Options
				where ProgramControl_Panel_Options_ID = '#arguments.templateId#'
			</cfquery>
</cfif>
		<cfreturn qgetsavedletters />
	</cffunction>

	<cffunction name="saveApprovalMetrics" output="false">
		<cfargument name="templateId" required="true" type="numeric" />
		<cfargument name="formScope" required="true" type="struct" />
			<cfquery name="saveApprovalMetrics" datasource="#application.datasource#">
				update Program_Control_Panel_Options
				set approval_margin_item = #Evaluate("arguments.formScope.approval_margin_item")#,
				approval_spend_item = #Evaluate("arguments.formScope.approval_spend_item")#,
				approval_program_margin = #Evaluate("arguments.formScope.approval_program_margin")#,
				approval_program_spend = #Evaluate("arguments.formScope.approval_program_spend")#,
				approval_uom = #Evaluate("arguments.formScope.approval_uom")#
				where ProgramControl_Panel_Options_ID = '#arguments.templateId#'
			</cfquery>
	</cffunction>

		<cffunction name="getApprovalMetrics" output="false">
		<cfargument name="templateId" required="true" type="numeric" />
			<cfset useLakebaseForqgetApprovalMetrics = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForqgetApprovalMetrics>
	<cftry>
		<cfset qgetApprovalMetrics = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#arguments.templateId#",
				"select" = "approval_margin_item,approval_spend_item,approval_program_margin,approval_program_spend,approval_uom"
			}), "approval_margin_item,approval_spend_item,approval_program_margin,approval_program_spend,approval_uom"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetApprovalMetrics = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetApprovalMetrics>
<cfquery name="qgetApprovalMetrics" datasource="#application.datasource#">
				select approval_margin_item,approval_spend_item,approval_program_margin,approval_program_spend,approval_uom
				from
				Program_Control_Panel_Options
				where ProgramControl_Panel_Options_ID = '#arguments.templateId#'
			</cfquery>
</cfif>
		<cfreturn qgetApprovalMetrics />
	</cffunction>

	<!--- get template settings --->
	<cffunction name="getTemplateSettings" output="false" access="remote">
		<cfargument name="programtype_id" required="true" type="string" />
			<cfquery name="qGetTemplateSettings" datasource="#application.datasource#">
				SELECT *
				FROM Program_Control_Panel_Options
				WHERE ProgramControl_Panel_Options_ID = '#trim(arguments.programtype_id)#'
			</cfquery>
		<cfreturn qGetTemplateSettings />
	</cffunction>

	<!--- get program categories --->
	<cffunction name="getProgramCategories" output="false">
		<cfargument name="programtype_id" required="true" type="string" />
		<cfquery name="qgetProgramCategories" datasource="#application.datasource#">
			SELECT Program_Category.Program_Category_ID, Program_Category.Program_Category
			FROM Program_Category
				INNER JOIN Category_Template_Mapping
				ON Program_Category.Program_Category_ID = Category_Template_Mapping.Program_Category_ID
				AND Category_Template_Mapping.Template_ID = '#arguments.ProgramType_ID#'
				AND Category_Template_Mapping.deleted = 0
		</cfquery>
	  <cfreturn qgetProgramCategories />
	</cffunction>

	<cffunction name="getProfileTemplates" output="false" returnType="query">
		<cfargument name="profileId" required="true" type="numeric" />
		<cfargument name="forbidAccessType" required="true" type="numeric" />
		<cfargument name="checkForPullbacks" required="false" type="numeric" default="1" />
		<cfargument name="templateId" required="false" type="numeric" default="-1" />
		<cfargument name="returnNewProfileEntry" required="false" type="numeric" default="0" />

		<cfset var forbidType = application.oApplicationAppSettingsManager.getApplicationAppSettings().getForbidAllowProfilesInTemplates() />

		<cfquery name="qGetProfileTemplates" datasource="#application.datasource#">
			SELECT	Program_Control_Panel_Options.ProgramControl_Panel_Options_ID Template_ID, Generic_type, Created_Type,
			<cfif forbidType eq 1><!------ forbid ----->
					CASE
					WHEN	Profile_Forbidden_Template.Profile_Forbidden_Template_ID IS NULL THEN 1
					ELSE	0
					END As Approve
			<cfelse><!------ allow ----->
					CASE
					WHEN	Profile_Forbidden_Template.Profile_Forbidden_Template_ID IS NULL THEN 0
					ELSE	1
					END As Approve
			</cfif>,
			CASE
			WHEN	Program_Control_Panel_Options.Pullbacks_On = 1
			AND
			(		Program_Control_Panel_Options.pullback_template_type = 2
					OR
					(		Program_Control_Panel_Options.pullback_template_type = 1
					AND		((Program_Control_Panel_Options.is_pullback_corporate_deal = 0
					AND		Program_Control_Panel_Options.pullback_from_corporate = 1) OR (Program_Control_Panel_Options.is_pullback_corporate_deal = 1) )
					)
			) THEN 1
			ELSE 0
			END As Pullback_Program

			FROM	Program_Control_Panel_Options

			LEFT JOIN Profile_Forbidden_Template
			ON		Profile_Forbidden_Template.Deleted = 0
			AND		Profile_Forbidden_Template.Template_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
			AND		Profile_Forbidden_Template.Profile_ID = <cfqueryparam value="#arguments.profileId#" cfsqltype="CF_SQL_INTEGER">
			AND		Profile_Forbidden_Template.Forbid_Access_Type = <cfqueryparam value="#arguments.forbidAccessType#" cfsqltype="CF_SQL_INTEGER">
			AND		Profile_Forbidden_Template.Forbid_Type = <cfqueryparam value="#forbidType#" cfsqltype="CF_SQL_INTEGER">

			WHERE	Program_Control_Panel_Options.Deleted = 0

			<cfif arguments.templateId neq -1>
			AND		Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = <cfqueryparam value="#arguments.templateId#" cfsqltype="CF_SQL_INTEGER">
			<cfelse>
			AND		Program_Control_Panel_Options.IsDominant = 1
			</cfif>
			<cfif arguments.checkForPullbacks>
			AND		Program_Control_Panel_Options.Pullbacks_On = 1
			AND
			(		Program_Control_Panel_Options.pullback_template_type = 2
					OR
					(		Program_Control_Panel_Options.pullback_template_type = 1
					AND		((Program_Control_Panel_Options.is_pullback_corporate_deal = 0
					AND		Program_Control_Panel_Options.pullback_from_corporate = 1) OR (Program_Control_Panel_Options.is_pullback_corporate_deal = 1))
					)
			)
			</cfif>

			<cfif arguments.returnNewProfileEntry>
			UNION

			SELECT	TOP 1 0 Template_ID, '' As Generic_type, 'New templates' As Created_Type,
			<cfif forbidType eq 1><!------ forbid ----->
					CASE
					WHEN	Profile_Forbidden_Template.Profile_Forbidden_Template_ID IS NULL THEN 1
					ELSE	0
					END As Approve
			<cfelse><!------ allow ----->
					CASE
					WHEN	Profile_Forbidden_Template.Profile_Forbidden_Template_ID IS NULL THEN 0
					ELSE	1
					END As Approve
			</cfif>,
			1 As Pullback_Program

			FROM	Program_Control_Panel_Options

			LEFT JOIN Profile_Forbidden_Template
			ON		Profile_Forbidden_Template.Deleted = 0
			AND		Profile_Forbidden_Template.Template_ID = 0
			AND		Profile_Forbidden_Template.Profile_ID = <cfqueryparam value="#arguments.profileId#" cfsqltype="CF_SQL_INTEGER">
			AND		Profile_Forbidden_Template.Forbid_Access_Type = <cfqueryparam value="#arguments.forbidAccessType#" cfsqltype="CF_SQL_INTEGER">
			AND		Profile_Forbidden_Template.Forbid_Type = <cfqueryparam value="#forbidType#" cfsqltype="CF_SQL_INTEGER">

			WHERE	Program_Control_Panel_Options.Deleted = 0
			</cfif>

			ORDER BY Generic_type, Created_Type
		</cfquery>

	  <cfreturn qGetProfileTemplates />

	</cffunction>

	<cffunction name="saveProfileTemplates" output="false" returnType="void">
		<cfargument name="profileId" required="true" type="numeric" />
		<cfargument name="forbidAccessType" required="true" type="numeric" />
		<cfargument name="templateIdList" required="true" type="string" />

		<cfset var forbidType = application.oApplicationAppSettingsManager.getApplicationAppSettings().getForbidAllowProfilesInTemplates() />

		<!------ get the distinct list of templates ----->
		<cfset qGetTemplates = getProfileTemplates(
									profileId = arguments.profileId,
									forbidAccessType = arguments.forbidAccessType,
									checkForPullbacks = 0,
									returnNewProfileEntry = 1) />
		<cfloop query="qGetTemplates">
			<cfset templateId = Template_ID />
			<cfset prevApprove = Approve />
			<cfif Pullback_Program EQ 0>
					<!------ delete entry alone ----->
					<cfset deleteProfileTemplates(
								profileId = arguments.profileId,
								templateId = templateId,
								forbidAccessType = arguments.forbidAccessType) />
				<cfif Template_ID NEQ 0>
					<cfstoredproc procedure="SP_ADJUST_PROGRAM_TEMPLATE_PROFILE_SETTINGS" datasource="#application.datasource#">
						<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@@CONTROL_PANEL_OPTIONS_ID" value="#templateId#" null="no">
					</cfstoredproc>
				</cfif>
			<cfelse>

				<cfset currentApprove = 0 />
				<cfif listFindNoCase(arguments.templateIdList, templateId) NEQ 0>
					<cfset currentApprove = 1 />
				</cfif>

				<cfif prevApprove NEQ currentApprove>
					<cfif forbidType EQ 1><!------ forbid ----->

						<cfif prevApprove EQ 0 AND currentApprove EQ 1>
							<!------ delete entry alone ----->
							<cfset deleteProfileTemplates(
										profileId = arguments.profileId,
										templateId = templateId,
										forbidAccessType = arguments.forbidAccessType) />
						<cfelseif prevApprove EQ 1 AND currentApprove EQ 0>
							<!------ insert entry alone ----->
							<cfset insertProfileTemplates(
										profileId = arguments.profileId,
										templateId = templateId,
										forbidAccessType = arguments.forbidAccessType,
										forbidType = forbidType) />
						</cfif>

					<cfelse><!------ allow ----->

						<cfif prevApprove EQ 0 AND currentApprove EQ 1>
							<!------ insert entry alone ----->
							<cfset insertProfileTemplates(
										profileId = arguments.profileId,
										templateId = templateId,
										forbidAccessType = arguments.forbidAccessType,
										forbidType = forbidType) />

						<cfelseif prevApprove EQ 1 AND currentApprove EQ 0>
							<!------ delete entry alone ----->
							<cfset deleteProfileTemplates(
										profileId = arguments.profileId,
										templateId = templateId,
										forbidAccessType = arguments.forbidAccessType) />
						</cfif>

					</cfif>
					<cfif Template_ID NEQ 0>
						<cfstoredproc procedure="SP_ADJUST_PROGRAM_TEMPLATE_PROFILE_SETTINGS" datasource="#application.datasource#">
							<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@@CONTROL_PANEL_OPTIONS_ID" value="#templateId#" null="no">
						</cfstoredproc>
					</cfif>

				</cfif>
			</cfif>

		</cfloop>

	</cffunction>

	<cffunction name="insertProfileTemplates" output="false" returnType="void">
		<cfargument name="profileId" required="true" type="numeric" />
		<cfargument name="forbidAccessType" required="true" type="numeric" />
		<cfargument name="forbidType" required="true" type="numeric" />
		<cfargument name="templateId" required="true" type="numeric" />

		<cfquery name="qInsertProfileTemplates" datasource="#application.datasource#">
			INSERT INTO Profile_Forbidden_Template
			(
				Profile_ID,
				Template_ID,
				Forbid_Access_Type,
				Forbid_Type
			)
			VALUES
			(
				<cfqueryparam value="#arguments.profileId#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#arguments.templateId#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#arguments.forbidAccessType#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#arguments.forbidType#" cfsqltype="CF_SQL_INTEGER">
			)
		</cfquery>

	</cffunction>

	<cffunction name="deleteProfileTemplates" output="false" returnType="void">
		<cfargument name="profileId" required="true" type="numeric" />
		<cfargument name="forbidAccessType" required="true" type="numeric" />
		<cfargument name="templateId" required="true" type="numeric" />

		<cfquery name="qDeleteProfileTemplates" datasource="#application.datasource#">
			DELETE 	FROM Profile_Forbidden_Template
			WHERE 	Profile_ID = <cfqueryparam value="#arguments.profileId#" cfsqltype="CF_SQL_INTEGER">
			<cfif arguments.templateId NEQ -1>
			AND		Template_ID = <cfqueryparam value="#arguments.templateId#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			AND		Forbid_Access_Type = <cfqueryparam value="#arguments.forbidAccessType#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

	</cffunction>

	<cffunction name="copyRevisionSettings" output="true">
		<cfargument name="fromTemplateId" required="true" type="numeric" />
		<cfargument name="toTemplateId" required="true" type="numeric" />

			<!--- First set the deleted bit to 1 for all the entries in the table --->
			<cfquery name="Set_Deleted" datasource="#application.datasource#">
				UPDATE	Template_Revision_Settings
				SET		Revision_Setting_Deleted = 1
				WHERE	Revision_Setting_Deleted = 0
				AND		Template_Revision_Settings.Template_ID = <cfqueryparam value="#arguments.toTemplateId#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>

			<cfquery name="qCopyRevisionSettings" datasource="#application.datasource#">
				INSERT INTO Template_Revision_Settings (Template_ID, Revision_Setting_Created_By, Revision_Setting_Created_On,
						Revision_Setting_Deleted, Apply_to_All, Title_Changes, Date_Changes,Date_Changes_End,
						Products_Added, Products_Removed, Products_Rates_Changes, Products_UOM_Changes,
						Lump_Sum_Changed, Lump_Sum_Created, Lump_Sum_Removed,
						Distributors_Added, Distributors_Removed,
						Operators_Added, Operators_Removed,
						Growth_Change_Target,
						Start_Date_Change, End_Date_Change,Payment_Frequency_Changes,
						Require_Private_Notes_Changed, Require_Public_Notes_Changed,
						End_Date_Revision_Not_Eligibile, End_Date_Revision_Not_Eligibile_Days,
						Claim_Mechanic_Changed )
				SELECT
						#arguments.toTemplateId# as Template_ID, Revision_Setting_Created_By, Revision_Setting_Created_On,
						Revision_Setting_Deleted, Apply_to_All, Title_Changes, Date_Changes,Date_Changes_End,
						Products_Added, Products_Removed, Products_Rates_Changes, Products_UOM_Changes,
						Lump_Sum_Changed, Lump_Sum_Created, Lump_Sum_Removed,
						Distributors_Added, Distributors_Removed,
						Operators_Added, Operators_Removed,
						Growth_Change_Target,
						Start_Date_Change, End_Date_Change,Payment_Frequency_Changes,
						Require_Private_Notes_Changed, Require_Public_Notes_Changed,
						End_Date_Revision_Not_Eligibile, End_Date_Revision_Not_Eligibile_Days,
						Claim_Mechanic_Changed
				FROM	Template_Revision_Settings
				WHERE	Revision_Setting_Deleted = 0
				AND		Template_ID = <cfqueryparam value="#arguments.fromTemplateId#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>

	</cffunction>

	<cffunction name="updatecomponentpaidto" output="false" returntype="string">
		<cfargument name="Component_Paid_To" type="numeric" required="true" />
		<cfargument name="discounttypeid" required="true" type="numeric"/>
		<cfargument name="compid" required="true" type="string" />
		<cfargument name="program_id" required="true" type="string" />
		<cfset paidtoexist = "false">
			<cfif arguments.discounttypeid EQ 1>
				<cfset useLakebaseForcheckpaidto = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_fixed_component")>
<cfif useLakebaseForcheckpaidto>
	<cftry>
		<cfset checkpaidto = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_fixed_component", {
				"program_fixed_component_name_id" = "eq.#arguments.compid#",
				"program_id" = "eq.#arguments.program_id#",
				"fixed_component_paid_to" = "eq.#arguments.Component_Paid_To#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheckpaidto = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheckpaidto>
<cfquery name="checkpaidto" datasource="#application.datasource#">
				select * from
				Program_Fixed_Component
				where Program_Fixed_Component_Name_ID = #arguments.compid#
				AND Program_Fixed_Component.Program_ID = '#arguments.program_id#'
				AND Program_Fixed_Component.Fixed_Component_Paid_to = '#arguments.Component_Paid_To#'
				</cfquery>
</cfif>
				<cfif checkpaidto.recordcount GT 0>
				<cfset paidtoexist = "true">
				<cfelse>
				<cfset useLakebaseForupdatecomponentpaidto = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_fixed_component")>
<cfif useLakebaseForupdatecomponentpaidto>
	<cftry>
		<cfset application.oLakebase.updateRows("program_fixed_component",
			{
				"program_fixed_component_name_id" = "eq.#arguments.compid#",
				"program_id" = "eq.#arguments.program_id#"
			},
			{
				"fixed_component_paid_to" = "#arguments.Component_Paid_To#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdatecomponentpaidto = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdatecomponentpaidto>
<cfquery name="updatecomponentpaidto" datasource="#application.datasource#">
				update Program_Fixed_Component
				set Fixed_Component_Paid_to = #arguments.Component_Paid_To#
				where Program_Fixed_Component_Name_ID = #arguments.compid#
				AND Program_Fixed_Component.Program_ID = '#arguments.program_id#'
				</cfquery>
</cfif>
				<cfset paidtoexist = "false">
			</cfif>
			<cfelseif arguments.discounttypeid EQ 2>
			<cfquery name="checkpaidto" datasource="#application.datasource#">
				select * from
				Program_Rebates_Component
				where Program_Rebates_Component_Name_ID = #arguments.compid#
				AND Program_ID = '#arguments.program_id#'
				AND Component_Paid_To = '#arguments.Component_Paid_To#'
				</cfquery>
				<cfif checkpaidto.recordcount GT 0>
				<cfset paidtoexist = "true">
				<cfelse>
				<cfquery name="updatecomponentpaidto" datasource="#application.datasource#">
				update Program_Rebates_Component
				set Component_Paid_To = #arguments.Component_Paid_To#
				where Program_Rebates_Component_Name_ID = #arguments.compid#
				AND Program_ID = '#arguments.program_id#'
				</cfquery>
				<cfset paidtoexist = "false">
			</cfif>
			<cfelseif arguments.discounttypeid EQ 3>
				<cfquery name="checkpaidto" datasource="#application.datasource#">
				select * from
				Program_Lump_Sums
				where Program_Lump_Sum_Name_ID = #arguments.compid#
				AND Program_ID = '#arguments.program_id#'
				AND Component_Paid_to = '#arguments.Component_Paid_To#'
				</cfquery>
				<cfif checkpaidto.recordcount GT 0>
				<cfset paidtoexist = "true">
				<cfelse>
				<cfquery name="updatecomponentpaidto" datasource="#application.datasource#">
				update Program_Lump_Sums
				set Component_Paid_to = #arguments.Component_Paid_To#
				where Program_Lump_Sum_Name_ID = #arguments.compid#
				AND Program_ID = '#arguments.program_id#'
				</cfquery>
				<cfset paidtoexist = "false">
				</cfif>
			<cfelseif arguments.discounttypeid EQ 4>
				<cfquery name="checkpaidto" datasource="#application.datasource#">
				select * from
				Program_Growth_Components
				where Program_Growth_Components_Name_Id = #arguments.compid#
				AND Program_ID = '#arguments.program_id#'
				AND Component_Paid_to = '#arguments.Component_Paid_To#'
				</cfquery>
				<cfif checkpaidto.recordcount GT 0>
				<cfset paidtoexist = "true">
				<cfelse>
				<cfquery name="updatecomponentpaidto" datasource="#application.datasource#">
				update Program_Growth_Components
				set Component_Paid_to = #arguments.Component_Paid_To#
				where Program_Growth_Components_Name_Id = #arguments.compid#
				AND Program_ID = '#arguments.program_id#'
				</cfquery>
				<cfset paidtoexist = "false">
				</cfif>
			<cfelseif arguments.discounttypeid EQ 10>
			<cfquery name="checkpaidto" datasource="#application.datasource#">
				select * from
				Program_Bidrequest_Component
				where Program_Bidrequest_Component_Name_ID = #arguments.compid#
				AND Program_ID = '#arguments.program_id#'
				AND Program_Bidrequest_Component_Paid_to = '#arguments.Component_Paid_To#'
				</cfquery>
				<cfif checkpaidto.recordcount GT 0>
				<cfset paidtoexist = "true">
				<cfelse>
				<cfquery name="updatecomponentpaidto" datasource="#application.datasource#">
				update Program_Bidrequest_Component
				set Program_Bidrequest_Component_Paid_to =
				#arguments.Component_Paid_To#
				where Program_Bidrequest_Component_Name_ID = #arguments.compid#
				AND Program_ID = '#arguments.program_id#'
				</cfquery>
				<cfset paidtoexist = "false">
			</cfif>
			</cfif>

			<cfreturn paidtoexist>
		</cffunction>

		<cffunction name="getalloprloctemplates" output="false" returnType="query">
			<cfargument name="templateId" required="false" type="numeric" default="-1" />
			<cfquery name="qgetoprloctemplates" datasource="#application.datasource#"> <!--- D30444:Evernt error when saving template revision ADDED DISTINCT --->
				select distinct Program_Control_Panel_Options.ProgramControl_Panel_Options_ID Template_ID,
					Program_Control_Panel_Options.Generic_Type,
					Program_Control_Panel_Options.Created_Type,
					ISNULL(Pullback_Default_Rate,100) Pullback_Default_Rate,
					ISNULL(Pullback_On,1) Pullback_On
				from Program_Control_Panel_Options
				left join template_pullback_defaults on
				template_pullback_defaults.Opr_Loc_Template_Parent_Id = Program_Control_Panel_Options.Template_Parent_Id
				and Corp_Template_Parent_Id = #arguments.templateId#
				and template_pullback_defaults.deleted = 0
				where Program_Control_Panel_Options.Deleted = 0
				AND		Program_Control_Panel_Options.IsDominant = 1
				AND 	((Program_Control_Panel_Options.generic_type = 'Distributor Trade/Shelter' and Program_Control_Panel_Options.Pullbacks_On = 1 and Program_Control_Panel_Options.is_pullback_corporate_deal = 0 and Program_Control_Panel_Options.pullback_from_corporate = 1) OR ((Program_Control_Panel_Options.generic_type = 'Operator Direct or HQ Programs' OR Program_Control_Panel_Options.generic_type = 'Operator-Deviated Pricing') and Program_Control_Panel_Options.Pullbacks_On = 1))
			</cfquery>
			<cfreturn qgetoprloctemplates>
		</cffunction>

		<cffunction name="getallprgoprloctemplates" output="false" returnType="query">
			<cfargument name="templateId" required="false" type="numeric" default="-1" />
			<cfargument name="programId" required="false" type="numeric" default="-1" />
			<cfquery name="qgetprgoprloctemplates" datasource="#application.datasource#">
				select Program_Control_Panel_Options.Generic_Type,Program_Control_Panel_Options.Created_Type, Program_Control_Panel_Options.ProgramControl_Panel_Options_ID Template_ID,
				case when template_pullback_program_defaults.Pullback_Default_Rate is not null then template_pullback_program_defaults.Pullback_Default_Rate
				else template_pullback_defaults.Pullback_Default_Rate
				end as Pullback_Default_Rate
				from Program_Control_Panel_Options
				left join template_pullback_defaults on
				template_pullback_defaults.Opr_Loc_Template_Id = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
				and template_pullback_defaults.Corp_Template_Id = #arguments.templateId#
				and template_pullback_defaults.deleted = 0
				left join template_pullback_program_defaults on
				template_pullback_program_defaults.Opr_Loc_Template_Id = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
				and template_pullback_program_defaults.Corp_Template_Id = #arguments.templateId#
				and program_id = #arguments.programId#
				and template_pullback_program_defaults.deleted = 0
				where Program_Control_Panel_Options.Deleted = 0
				AND		Program_Control_Panel_Options.IsDominant = 1
				AND 	((Program_Control_Panel_Options.generic_type = 'Distributor Trade/Shelter' and Program_Control_Panel_Options.Pullbacks_On = 1 and Program_Control_Panel_Options.is_pullback_corporate_deal = 0 and Program_Control_Panel_Options.pullback_from_corporate = 1) OR ((Program_Control_Panel_Options.generic_type = 'Operator Direct or HQ Programs' OR Program_Control_Panel_Options.generic_type = 'Operator-Deviated Pricing') and Program_Control_Panel_Options.Pullbacks_On = 1))
			</cfquery>
			<cfreturn qgetprgoprloctemplates>
		</cffunction>

	<!--- D11689: On Revision force Biz Considerations --->
	<cffunction name="getTemplateRevisionSettings" output="false" returntype="query" access="remote">
		<cfargument name="templateId" required="true" type="numeric" />

		<cfquery name="qTemplateRevisionSettings" datasource="#application.datasource#">
			select		Template_Revision_Settings.*, _Users.Name_First, Name_Last
			from		Template_Revision_Settings
						left join _Users on
						Template_Revision_Settings.Revision_Setting_Created_By =  _Users.User_ID
			where		Revision_Setting_Deleted = 0
			and			Template_Revision_Settings.Template_ID = <cfqueryparam value="#arguments.templateId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfreturn qTemplateRevisionSettings>
	</cffunction>

	<cffunction name="getTemplatesByGenericType" access="public" returntype="query">
		<cfargument name="genType" required="false" type="string"  default=""/>
		<cfargument name="coMainId" required="true" type="UUID">
		<cfargument name="filterbyUBS" required="false" type="numeric" default="1">
		<!---
			D43263: Template filter by segment/Anand Rao/04-Jun-14
			If Business Segment is ON
			From the main template settings page
			Only show the user those templates the ones with a segment that the user also has
		--->
		<cfset appSettings = appSettings = application.appSettingsGet />
		<cfif ((appSettings.Filter_Business_Segments EQ 1 AND ( isdefined('FORM.showAllSegments') AND FORM.showAllSegments EQ 1)) OR appSettings.Filter_Business_Segments EQ 0)>
			<cfquery name="qGetTemplates" datasource="#application.datasource#">
				SELECT 		*
				FROM 		Program_Control_Panel_Options
				WHERE 	Company_Main_ID = <cfqueryparam value="#arguments.coMainId#" cfsqltype="cf_sql_idstamp">
				AND Deleted = 0
				AND IsDominant = 1
				AND Generic_Type = <cfqueryparam value="#arguments.genType#" cfsqltype="cf_sql_varchar">
				ORDER BY 	Created_Type asc
			</cfquery>
		<cfelse>
			<cfquery name="qGetTemplates" datasource="#application.datasource#">
				SELECT 		DISTINCT PCPO.*
				FROM 		Program_Control_Panel_Options PCPO
					INNER JOIN 	Template_Business_Segment TBS
					ON TBS.Template_ID = PCPO.ProgramControl_Panel_Options_ID AND TBS.Deleted = 0
					INNER JOIN Business_Segment BS
					ON BS.Business_Segment_ID =  TBS.Business_Segment_ID
					<cfif arguments.filterbyUBS>
				INNER JOIN User_Business_Segment UBS
						ON UBS.Business_Segment_ID = BS.Business_Segment_ID
						AND UBS.User_ID = '#request.accessStructure.User_Id#'
						AND UBS.Deleted = 0
					</cfif>
				WHERE 		PCPO.Company_Main_ID = <cfqueryparam value="#arguments.coMainId#" cfsqltype="cf_sql_idstamp">
							AND PCPO.Deleted = 0
							AND PCPO.IsDominant = 1
					<cfif len(arguments.genType)>
							AND PCPO.Generic_Type = <cfqueryparam value="#arguments.genType#" cfsqltype="cf_sql_varchar">
					</cfif>
							AND BS.deleted = 0
							AND BS.Active = 1
				 ORDER BY 	PCPO.Created_Type asc
			</cfquery>
		</cfif>
		<cfreturn qGetTemplates />
	</cffunction>

	<!--- Get all the programs with Ez Button On which do not have the Ez_Contract_ID of the latest template.
	      The comparison of the 'Ez_Contract_ID' is made in the Contract_products table
	--->
	<cffunction name="getEZProgramsLatestTemplateSettings" access="public" returntype="query">
		<cfargument name="First_Parent_ID" required="true" type="string" />
		<cfargument name="EZ_Contract_ID" required="true" type="string" />

		<cfquery name="qgetEZProgramsLatestTemplateSettings" datasource="#application.datasource#">
		SELECT Contract_Number, Contract_Title, Contract_Status_Types.Contract_Status_Type_Desc As Contract_Status,
			RSP_User.Name_First + ' ' + RSP_User.Name_Last As RSP_Name, Creator_User.Name_First + ' ' + Creator_User.Name_Last As Creator_Name,
			CONVERT(char(10),Contract_Created_Date,101) As Created_Date,RFA_User.Name_First + ' ' + RFA_User.Name_Last As RFA_Name, CONVERT(char(10),Broker_Approved_Date,101) As RFA_Date
		FROM Contract_Main
		INNER JOIN Contract_Status_Types
		ON Contract_Status_Types.Contract_Status_Type_ID = Contract_Main.Contract_Status_Type_IDX
		LEFT JOIN _Users RFA_User
		ON RFA_User.User_ID = Contract_Main.Broker_User_ID
		LEFT JOIN _Users Creator_User
		ON Creator_User.User_ID = Contract_Main.Creator_ID
		LEFT JOIN _Users RSP_User
		ON RSP_User.User_ID = Contract_Main.Responsible_User_ID
		INNER JOIN Program_Control_Panel_Options
		ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
		WHERE Program_Control_Panel_Options.First_Parent_ID = '#arguments.First_Parent_ID#'
		AND Contract_Main.Deleted = 0
		<!--- Only WIP and RFA --->
		AND Contract_Main.Contract_Status_Type_IDX IN (1,2)
		<!--- Either it is a new program (not a revision) OR If it's a revision, then "Update with latest template settings on Revise"
		      should be On.
		 --->
		AND (Contract_Main.Revision_version = 1 OR Program_Control_Panel_Options.EzButton_Update_With_Latest_Template_Settings_On_Revise = 1)
		AND '#EZ_Contract_ID#' <>
		(
		SELECT TOP 1 EZ_Contract_ID
		FROM Contract_products
		WHERE Contract_Main_ID = Contract_Main.Contract_Main_ID
		AND Deleted = 0
		)
		ORDER BY Contract_Main.Contract_Number
		</cfquery>

		<cfreturn qgetEZProgramsLatestTemplateSettings />
	</cffunction>

  <!---
				Dev Notes: D23601/Anand Rao/01-Aug-10
				Margin Page, Items to Exclude
        This function is used to get all the Active and Dominant templates based on
        the appsettings.
  --->

  <cffunction access="remote" name="getAllTemplates" output="false" returntype="query">
  	  <!--- D29824: new settings --->
	<cfargument name="Template_ID" required="false" type="numeric" default="0"/>
	<cfargument name="businessSegmentId" required="false" type="numeric" default="0" />
	<cfargument name="uploadFilter" required="false" type="numeric" default="0" />
	<!--- D29824: new settings --->
    <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
    <cfquery name="qGetAllTemplates" datasource="#application.datasource#">
    	SELECT 	Program_Control_Panel_Options.*
    	FROM 		Program_Control_Panel_Options
					<cfif arguments.businessSegmentId>
					inner join Template_Business_Segment on Template_Business_Segment.Template_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
    				and Template_Business_Segment.Deleted = 0 and Template_Business_Segment.Business_Segment_ID = '#arguments.businessSegmentId#'
					</cfif>
    	WHERE 		Company_Main_ID = '#request.AccessStructure.Company_Main_ID#'
					<!--- D29824: new settings --->
					<cfif arguments.Template_ID>
					AND ProgramControl_Panel_Options_id =  <cfqueryparam value="#arguments.Template_ID#" cfsqltype="CF_SQL_INTEGER">
					</cfif>
					<!--- D29824: new settings --->
    				AND Program_Control_Panel_Options.Deleted = 0
    				AND Active = 1
    				AND IsDominant = 1
    				<!------ DEV NOTE: DRK 9674 : if the template - restrict group type is class code alone ----->
    				<cfif appSettings.getDisplayDistributorOffInvoice() eq 0>
    				AND Generic_Type != 'Distributor Off-Invoice'
    				</cfif>
    				<cfif appSettings.getDisplayProposal() eq 0>
    				AND Generic_Type != 'Bid Request'
    				</cfif>
    				<cfif appSettings.getDisplayUSDANOI() eq 0>
    				AND Generic_Type != 'USDA NOI'
    				</cfif>
					<cfif arguments.uploadFilter>
					AND Include_Program_Upload_Template_List = <cfqueryparam value="1" cfsqltype="CF_SQL_BIT">
					</cfif>
		
    	ORDER BY 	Generic_Type, Created_Type asc

    </cfquery>
	<cfreturn qGetAllTemplates />
</cffunction>

 <cffunction name="getAllTemplatesForPGWithFilters" access="public" returntype="query">
    <cfargument name="Sort_Order" required="false" type="string" default="ASC" />
	<cfargument name="SearchKW" required="false" type="string" default="" />
    <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
    <cfquery name="qGetAllTemplatesForPGWithFilters" datasource="#application.datasource#">
    SELECT   DISTINCT Program_Control_Panel_Options.*,TF.*
    FROM           Program_Control_Panel_Options
    LEFT JOIN Template_Filters TF ON
                       TF.Parent_Template_Id = Program_Control_Panel_Options.First_Parent_ID AND
                       TF.Deleted = 0
                       -- AND TF.Status='ACTIVE'
    WHERE Company_Main_ID = '#request.AccessStructure.Company_Main_ID#'
                               AND Program_Control_Panel_Options.Deleted = 0
                               AND Active = 1
                               AND IsDominant = 1
                               AND programcontrol_panel_options_id
                               NOT IN
                                      (       SELECT  DISTINCT Template_ID
                                              FROM Profile_Forbidden_Template
                                              WHERE   Deleted = 0
                                                             AND Forbid_Type = 1
                                                             AND     Forbid_Access_Type = 1
                                                             AND profile_id = 6
                                      )
            <cfif appSettings.getDisplayDistributorOffInvoice() eq 0>
    				AND Generic_Type != 'Distributor Off-Invoice'
    				</cfif>
    				<cfif appSettings.getDisplayProposal() eq 0>
    				AND Generic_Type != 'Bid Request'
    				</cfif>
    				<cfif appSettings.getDisplayUSDANOI() eq 0>
    				AND Generic_Type != 'USDA NOI'
    				</cfif>

			<cfif (isDefined("arguments.SearchKW") AND arguments.SearchKW NEQ "")>
				AND (Program_Control_Panel_Options.Created_Type like '%#arguments.SearchKW#%'
				OR Program_Control_Panel_Options.Program_Description like '%#arguments.SearchKW#%')
			</cfif>
        ORDER BY  Created_Type  #arguments.Sort_Order#

    </cfquery>
	<cfreturn qGetAllTemplatesForPGWithFilters />
</cffunction>

 <cffunction name="fnSaveFilterProducts" access="public" returntype="string">
    <cfargument name="UserID" required="true" type="string"  />
    <cfargument name="stForm" required="true" type="any" default="" />
    <cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />
    <cfset PGManager = CreateObject("component", "components.settings.PlanningGroups.PlanningGroupsManager").init() />

    <cfset qGetTopLevelGroups = GroupDataManager.getProductGroupsData() />
    <cfset qryGetGroupTemplateByTemplateID = PGManager.fnGetGroupTemplateByTemplateID(arguments.stForm.TemplateID,arguments.stForm.itemPGGroupType,arguments.stForm.TEMPLATEFILTERSID)/>

    <cfset errorCount = 0 />
    <cfset returnVal = "" />
    <cfset addedVal = "" />
    <cfset FilterValsChecked="" />

      <cfloop query="qGetTopLevelGroups">
        <cfset prodGroupExistsAlready = 0 />
          <cfset useLakebaseForqryCheckPGTS = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("product_group_template_selection")>
<cfif useLakebaseForqryCheckPGTS>
	<cftry>
		<cfset qryCheckPGTS = application.oLakebase.toQuery(
			application.oLakebase.selectRows("product_group_template_selection", {
				"product_group_level_id" = "eq.#qGetTopLevelGroups.Product_Group_Level_ID#",
				"template_id" = "eq.#arguments.stForm.TemplateID#",
				"active" = "eq.1",
				"deleted" = "eq.0",
				"select" = "product_group_template_selection_id"
			}), "product_group_template_selection_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryCheckPGTS = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryCheckPGTS>
<cfquery name="qryCheckPGTS" datasource="#application.datasource#">
            SELECT  Product_Group_Template_Selection_ID
            FROM Product_Group_Template_Selection
            WHERE Product_Group_Level_ID = #qGetTopLevelGroups.Product_Group_Level_ID#
            AND Template_ID = #arguments.stForm.TemplateID#
            AND Active = 1
            AND Deleted = 0
          </cfquery>
</cfif>
        <cfloop query="qryGetGroupTemplateByTemplateID">
          <cfif qryGetGroupTemplateByTemplateID.Group_Level_ID EQ qGetTopLevelGroups.Product_Group_Level_ID>
          	<cfset prodGroupExistsAlready = 1 />
          </cfif>
          <cfif prodGroupExistsAlready EQ 1>
	          <cfset SearchChecked = "0" />
	          <cfset GroupChecked = "0" />
	          <cfset FiltersChecked = "0" />
			  <cfset PrgVolBYAttributeChecked = "0" />
	          <cfloop index="colName" list="#arguments.stForm.fieldnames#">

	            <cfif (FindNoCase("CHKBOXSEARCHPROD_#qryGetGroupTemplateByTemplateID.Group_Level_ID#_",colName) NEQ 0)>
	              <cfset SearchChecked = "1" />
	              <cfset temp2 = StructDelete(arguments.stForm, colName) />
	            </cfif>
	            <cfif (FindNoCase("CHKBOXGROUPPROD_#qryGetGroupTemplateByTemplateID.Group_Level_ID#_",colName) NEQ 0)>
	              <cfset GroupChecked = "1" />
	              <cfset temp2 = StructDelete(arguments.stForm, colName) />
	            </cfif>
	            <cfif (FindNoCase("CHKBOXFILTERSPROD_#qryGetGroupTemplateByTemplateID.Group_Level_ID#_",colName) NEQ 0)>
	              <cfset FiltersChecked = "1" />
	              <cfset FilterValsChecked = Listappend(FilterValsChecked,qryGetGroupTemplateByTemplateID.Group_Level_ID) />
	              <cfset temp2 = StructDelete(arguments.stForm, colName) />
	            </cfif>
	            <cfif (FindNoCase("CHKBOXPRGVOLBYATTRIBUTE_#qryGetGroupTemplateByTemplateID.Group_Level_ID#_",colName) NEQ 0)>
	              <cfset PrgVolBYAttributeChecked = "1" />
	              <cfset temp2 = StructDelete(arguments.stForm, colName) />
	            </cfif>
	          </cfloop>  <!--- End Loop colname, Fieldnames --->
	          <!--- EXISTING FIELD UPDATE --->
	          <cfquery name="updGroupTemplate" datasource="#application.datasource#">
	            UPDATE Group_Template
	            SET
	              Allow_In_Search = #SearchChecked#,
	              Allow_In_Group_Search = #GroupChecked#,
	              Allow_Filter = #FiltersChecked#,
				  Prg_Vol_By_Attribute = #PrgVolBYAttributeChecked#,
	              <cfif  SearchChecked EQ "0" AND  GroupChecked EQ "0" AND FiltersChecked EQ "0" AND PrgVolBYAttributeChecked EQ "0">
		              Active = 0,
		              Deleted = 1,
	              </cfif>
	              Updated_Date = GetDate(),
	              Updated_By =  '#arguments.UserID#'
	            WHERE Group_Template_ID = #qryGetGroupTemplateByTemplateID.Group_Template_ID#
	          </cfquery>
	          <cfif FiltersChecked EQ "0">
		          <cfquery name="updProdGroupSelection" datasource="#application.datasource#">
		            UPDATE Product_Group_Template_Selection
		            SET Active = 0,
			            Deleted = 1,
			            Updated_Date = GetDate(),
			            Updated_By =  '#arguments.UserID#'
		            WHERE
		                  Template_ID = #arguments.stForm.TemplateID#
			            AND   Product_Group_Level_ID = #qryGetGroupTemplateByTemplateID.Group_Level_ID#
		           </cfquery>
	           </cfif>
          </cfif> <!--- END if prodGroupExistsAlready EQ 1 --->
        </cfloop> <!--- End Loop query="qryGetGroupTemplateByTemplateID" --->
      <cfif prodGroupExistsAlready EQ 0>
      <!--- Check for the existance of this record in the FORM scope and do an insert as it does not exists currently --->
          <cfset SearchChecked = "0" />
          <cfset GroupChecked = "0" />
          <cfset FiltersChecked = "0" />
		  <cfset PrgVolBYAttributeChecked = "0" />
          <cfloop index="colName" list="#arguments.stForm.fieldnames#">
            <cfif (FindNoCase("CHKBOXSEARCHPROD_#qGetTopLevelGroups.Product_Group_Level_ID#_",colName) NEQ 0)>
              <cfset SearchChecked = "1" />
              <cfset temp2 = StructDelete(arguments.stForm, colName) />
            </cfif>
            <cfif (FindNoCase("CHKBOXGROUPPROD_#qGetTopLevelGroups.Product_Group_Level_ID#_",colName) NEQ 0)>
              <cfset GroupChecked = "1" />
              <cfset temp2 = StructDelete(arguments.stForm, colName) />
            </cfif>
            <cfif (FindNoCase("CHKBOXFILTERSPROD_#qGetTopLevelGroups.Product_Group_Level_ID#_",colName) NEQ 0)>
              <cfset FiltersChecked = "1" />
              <cfset FilterValsChecked = Listappend(FilterValsChecked,qGetTopLevelGroups.Product_Group_Level_ID) />
              <cfset temp2 = StructDelete(arguments.stForm, colName) />
            </cfif>
			<cfif (FindNoCase("CHKBOXPRGVOLBYATTRIBUTE_#qGetTopLevelGroups.Product_Group_Level_ID#_",colName) NEQ 0)>
              <cfset PrgVolBYAttributeChecked = "1" />
              <cfset temp2 = StructDelete(arguments.stForm, colName) />
            </cfif>
          </cfloop>
           <cfif  SearchChecked EQ "1" OR GroupChecked EQ "1" OR FiltersChecked EQ "1" OR PrgVolBYAttributeChecked EQ "1">
            <cfset useLakebaseForqryChkISPG = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("product_group_level")>
<cfif useLakebaseForqryChkISPG>
	<cftry>
		<cfset qryChkISPG = application.oLakebase.toQuery(
			application.oLakebase.selectRows("product_group_level", {
				"product_group_level_id" = "eq.#qGetTopLevelGroups.Product_Group_Level_ID#",
				"limit" = "1",
				"select" = "is_pg"
			}), "is_pg"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryChkISPG = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryChkISPG>
<cfquery name="qryChkISPG" datasource="#application.datasource#">
                SELECT TOP 1 IS_PG  FROM
                Product_group_level
                WHERE Product_Group_Level_ID = #qGetTopLevelGroups.Product_Group_Level_ID#
            </cfquery>
</cfif>
            <cfquery name="qInsPGTypeTemplate" datasource="#application.datasource#">
            	INSERT INTO Group_Template
            	( Template_ID,
	              Group_Level_ID,
	              PG_Group_Type,
	              Allow_in_Search,
	              Allow_in_Group_Search,
	              Allow_Filter,
				  Prg_Vol_By_Attribute,
	              Active,
	              Deleted,
	              Created_Date,
	              Created_By,
	              PG_Flag,
	              Updated_From)
	            VALUES
	             (#arguments.stForm.TemplateID#,
	              #qGetTopLevelGroups.Product_Group_Level_ID#,
	              #arguments.stForm.itemPGGroupType#,
	              #SearchChecked#,
	              #GroupChecked#,
	              #FiltersChecked#,
				  #PrgVolBYAttributeChecked#,
	              <cfqueryparam value="1" cfsqltype="cf_sql_int"/>,
	              <cfqueryparam value="0" cfsqltype="cf_sql_int"/>,
	              GetDate(),
	              <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>,
	              <cfif ((qryChkISPG.RecordCount EQ 1) AND (qryChkISPG.IS_PG EQ 1))>1<cfelse>0</cfif>,
	              <cfqueryparam value="Template Page - Product Filter" cfsqltype="cf_sql_varchar"/>
	              )
          	</cfquery>

           </cfif><!--- if SearchChecked EQ "1" OR GroupChecked EQ "1" OR FiltersChecked EQ "1" --->
      	</cfif><!---  <cfif prodGroupExistsAlready EQ 0> --->

	 	<cfif (qryCheckPGTS.RecordCount EQ 0 AND ListFindNoCase(FilterValsChecked,qGetTopLevelGroups.Product_Group_Level_ID) GTE 1)>

	       <cfquery name="updGroupTemplateFilters" datasource="#application.datasource#">
	            UPDATE Group_Template
	            SET  Allow_Filter = 0,
	                 Updated_Date = GetDate(),
	                 Updated_By =  '#arguments.UserID#',
									 Updated_From = 'Program Wizard - Template Filters page'
	            WHERE Template_ID = #arguments.stForm.TemplateID#
	            AND PG_Group_Type = 1
	            AND Group_Level_ID = #qGetTopLevelGroups.Product_Group_Level_ID#
	            AND Active = 1
	            AND Deleted = 0
	       </cfquery>
	       <cfset errorCount = errorCount + 1 />
	       <cfset addedVal = ListAppend(addedVal, qGetTopLevelGroups.Group_Level_Desc) />
	       <cfset returnVal = returnVal & errorCount & ". #qGetTopLevelGroups.Group_Level_Desc#" & "\n"  />
	    </cfif>
    </cfloop>

	<!--- Populate Group records if applicable --->
		<cfif application.appSettingsGet.getTemplateMultipleProductAttrGroups() EQ 1 AND this.get(arguments.stForm.TemplateID).Active EQ 0 >
			 <cfquery name="getGroupTemplateCount" datasource="#application.datasource#">
	            SELECT Count(Template_ID)
				FROM Group_Template
	            WHERE Template_ID = #arguments.stForm.TemplateID# AND
					Allow_in_Group_Search = 1 AND
					PG_Flag = 0
			 </cfquery>
			 <cfif getGroupTemplateCount.recordcount GT 0>
			 	 <cfquery name="CreateMultiProductAttrGroups" datasource="#application.datasource#">
				  	  EXEC Create_Multi_Product_Attr_Groups #arguments.stForm.TemplateID#
				 </cfquery>
			  </cfif>

		</cfif>
   <!--- TODO:
   INSERT INTO THE Group_Template table, values for the current template
   if product_level_id already exists then update the 3 check boxes alone
   if the Product_level_ID does not exist insert a new record.
   if it exists in the table and removed in the page then
   set the flag to deleted.
  --->
    <cfif (errorCount EQ 1)>
  <cfset returnVal = "The following Allow Filter was unchecked as no filter items were selected:\n\n #returnVal# \n" />
  <cfelseif (errorCount GT 1)>
  <cfset returnVal = "The following Allow Filter were unchecked as no filter items were selected:\n\n #returnVal# \n" />
  </cfif>
   <cfreturn returnVal/>
  </cffunction>

  <cffunction name="fnSaveFilterCustomers" access="public" returntype="string">
    <cfargument name="UserID" required="true" type="string"  />
    <cfargument name="stForm" required="true" type="any" default="" />
    <cfset DistGroupDataManager = CreateObject("component", "components.customer.Group.DataManager").init() />
    <!--- <cfset GroupDataManager = CreateObject("component", "components.customer.Group.DataManager") /> --->
    <cfset PGManager = CreateObject("component", "components.settings.PlanningGroups.PlanningGroupsManager").init() />

    <cfset errorCount = 0 />
    <cfset returnVal = "" />
    <cfset addedVal = "" />
    <cfset FilterValsChecked="" />


   <!---  <cfset qGetTopLevelGroups = GroupDataManager.getProductGroupsData() /> --->
    <cfquery name="qryDistList" datasource="#application.datasource#">
      SELECT DISTINCT(Distributor_Group_Level_ID) FROM Distributor_Group_Level WHERE Active= 1 AND Deleted = 0  AND Distributor_Group_Level_ID NOT IN (23, 24, 25)
    </cfquery>
   <cfset qGetTopLevelGroups = DistGroupDataManager.getDistributorLevels(1, "#ValueList(qryDistList.Distributor_Group_Level_ID)#", "") />

    <cfset qryGetGroupTemplateByTemplateID = PGManager.fnGetGroupTemplateByTemplateID(arguments.stForm.TemplateID,arguments.stForm.cusPGGroupType)/>
      <cfloop query="qGetTopLevelGroups">
        <cfset distGroupExistsAlready = 0 />
          <cfset useLakebaseForqryCheckCGTS = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("customer_group_template_selection")>
<cfif useLakebaseForqryCheckCGTS>
	<cftry>
		<cfset qryCheckCGTS = application.oLakebase.toQuery(
			application.oLakebase.selectRows("customer_group_template_selection", {
				"distributor_group_level_id" = "eq.#qGetTopLevelGroups.Distributor_Group_Level_ID#",
				"template_id" = "eq.#arguments.stForm.TemplateID#",
				"active" = "eq.1",
				"deleted" = "eq.0",
				"select" = "customer_group_template_selection_id"
			}), "customer_group_template_selection_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryCheckCGTS = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryCheckCGTS>
<cfquery name="qryCheckCGTS" datasource="#application.datasource#">
            SELECT  Customer_Group_Template_Selection_ID
            FROM Customer_Group_Template_Selection
            WHERE Distributor_Group_Level_ID = #qGetTopLevelGroups.Distributor_Group_Level_ID#
            AND Template_ID = #arguments.stForm.TemplateID#
            AND Active = 1
            AND Deleted = 0
          </cfquery>
</cfif>
        <cfloop query="qryGetGroupTemplateByTemplateID">

          <cfif qryGetGroupTemplateByTemplateID.Group_Level_ID EQ qGetTopLevelGroups.Distributor_Group_Level_ID>
            <cfset distGroupExistsAlready = 1 />
          </cfif>
         <cfif distGroupExistsAlready EQ 1>
          <cfset SearchChecked = "0" />
          <cfset GroupChecked = "0" />
          <cfset FiltersChecked = "0" />
         <cfloop index="colName" list="#arguments.stForm.fieldnames#">

            <cfif (FindNoCase("CHKBOXSEARCHDIST_#qryGetGroupTemplateByTemplateID.Group_Level_ID#_",colName) NEQ 0)>
              <cfset SearchChecked = "1" />
              <cfset temp2 = StructDelete(arguments.stForm, colName) />
            </cfif>
            <cfif (FindNoCase("CHKBOXGROUPDIST_#qryGetGroupTemplateByTemplateID.Group_Level_ID#_",colName) NEQ 0)>
              <cfset GroupChecked = "1" />
              <cfset temp2 = StructDelete(arguments.stForm, colName) />
            </cfif>
            <cfif (FindNoCase("CHKBOXFILTERSDIST_#qryGetGroupTemplateByTemplateID.Group_Level_ID#_",colName) NEQ 0)>
             <cfset FiltersChecked = "1" />
             <cfset FilterValsChecked = Listappend(FilterValsChecked,qryGetGroupTemplateByTemplateID.Group_Level_ID) />
             <!---  <cfif qryCheckCGTS.RecordCount GTE 1>
                <cfset FiltersChecked = "1" />
              <cfelse>
                <cfset FiltersChecked = "0" />
                <cfset errorCount = errorCount + 1 />

                <cfif (ListFindNoCase(addedVal,qGetTopLevelGroups.Group_Level_Desc) EQ 0)>
                  <cfset addedVal = ListAppend(addedVal, qGetTopLevelGroups.Group_Level_Desc) />
                  <cfset returnVal =  "#qGetTopLevelGroups.Group_Level_Desc#" & "\n" & returnVal />
                </cfif>
              </cfif>  ---><!---   <cfif qryCheckCGTS.RecordCount GTE 1> --->

              <cfset temp2 = StructDelete(arguments.stForm, colName) />
            </cfif>
          </cfloop>  <!--- End Loop colname, Fieldnames --->
          <!--- EXISTING FIELD UPDATE --->

          <cfquery name="updGroupTemplate" datasource="#application.datasource#">
            UPDATE Group_Template
            SET
              Allow_In_Search = #SearchChecked#,
              Allow_In_Group_Search = #GroupChecked#,
              Allow_Filter = #FiltersChecked#,
              <cfif  SearchChecked EQ "0" AND  GroupChecked EQ "0" AND FiltersChecked EQ "0">
              Active = 0,
              Deleted = 1,
              </cfif>
              Updated_Date = GetDate(),
              Updated_By =  '#arguments.UserID#'
            WHERE Group_Template_ID = #qryGetGroupTemplateByTemplateID.Group_Template_ID#
          </cfquery>
          <cfif FiltersChecked EQ "0">
           <cfquery name="updDistGroupSelection" datasource="#application.datasource#">
            UPDATE Customer_Group_Template_Selection
            SET Active = 0,
            Deleted = 1,
            Updated_Date = GetDate(),
            Updated_By =  '#arguments.UserID#'
            WHERE
                  Template_ID = #arguments.stForm.TemplateID#
            AND   Distributor_Group_Level_ID = #qryGetGroupTemplateByTemplateID.Group_Level_ID#
           </cfquery>
          </cfif>
          </cfif> <!--- distGroupExistsAlready EQ 1 --->
        </cfloop> <!--- End Loop query="qryGetGroupTemplateByTemplateID" --->

      <cfif distGroupExistsAlready EQ 0>
      <!--- Check for the existance of this record in the FORM scope and do an insert as it does not exists currently --->
          <cfset SearchChecked = "0" />
          <cfset GroupChecked = "0" />
          <cfset FiltersChecked = "0" />
          <cfloop index="colName" list="#arguments.stForm.fieldnames#">
            <cfif (FindNoCase("CHKBOXSEARCHDIST_#qGetTopLevelGroups.Distributor_Group_Level_ID#_",colName) NEQ 0)>
              <cfset SearchChecked = "1" />
              <cfset temp2 = StructDelete(arguments.stForm, colName) />
            </cfif>
            <cfif (FindNoCase("CHKBOXGROUPDIST_#qGetTopLevelGroups.Distributor_Group_Level_ID#_",colName) NEQ 0)>
              <cfset GroupChecked = "1" />
              <cfset temp2 = StructDelete(arguments.stForm, colName) />
            </cfif>
            <cfif (FindNoCase("CHKBOXFILTERSDIST_#qGetTopLevelGroups.Distributor_Group_Level_ID#_",colName) NEQ 0)>
              <cfset FiltersChecked = "1" />
              <cfset FilterValsChecked = Listappend(FilterValsChecked,qryGetGroupTemplateByTemplateID.Group_Level_ID) />
              <cfset temp2 = StructDelete(arguments.stForm, colName) />
            </cfif>
          </cfloop>
           <cfif  SearchChecked EQ "1" OR GroupChecked EQ "1" OR FiltersChecked EQ "1">
            <cfquery name="qryChkISPG" datasource="#application.datasource#">
                SELECT TOP 1 IS_PG  FROM
                Distributor_group_level
                WHERE Distributor_Group_Level_ID = #qGetTopLevelGroups.Distributor_Group_Level_ID#
            </cfquery>
            <cfif qryCheckCGTS.RecordCount EQ 0>
              <cfset FiltersChecked = 0 />
            </cfif>
            <cfquery name="qInsPGTypeTemplate" datasource="#application.datasource#">
            INSERT INTO Group_Template
            ( Template_ID,
              Group_Level_ID,
              PG_Group_Type,
              Allow_in_Search,
              Allow_in_Group_Search,
              Allow_Filter,
              Active,
              Deleted,
              Created_Date,
              Created_By,
              PG_Flag,
              Updated_From)
            VALUES
             (#arguments.stForm.TemplateID#,
              #qGetTopLevelGroups.Distributor_Group_Level_ID#,
              #arguments.stForm.cusPGGroupType#,
              #SearchChecked#,
              #GroupChecked#,
              #FiltersChecked#,
              <cfqueryparam value="1" cfsqltype="cf_sql_int"/>,
              <cfqueryparam value="0" cfsqltype="cf_sql_int"/>,
              GetDate(),
              <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>,
              <cfif ((qryChkISPG.RecordCount EQ 1) AND (qryChkISPG.IS_PG EQ 1))>1<cfelse>0</cfif>,
              <cfqueryparam value="Template Page - Customer Filter" cfsqltype="cf_sql_varchar"/>
              )
          </cfquery>

           </cfif><!--- if SearchChecked EQ "1" OR GroupChecked EQ "1" OR FiltersChecked EQ "1" --->
      </cfif><!---  <cfif prodGroupExistsAlready EQ 0> --->
  <cfif (qryCheckCGTS.RecordCount EQ 0 AND ListFindNoCase(FilterValsChecked,qGetTopLevelGroups.Distributor_Group_Level_ID) GTE 1)>

       <cfquery name="updGroupTemplateFilters" datasource="#application.datasource#">
            UPDATE Group_Template
            SET  Allow_Filter = 0,
            Updated_Date = GetDate(),
            Updated_By =  '#arguments.UserID#',
						Updated_From = 'Program Wizard - Template Filters page'
            WHERE Template_ID = #arguments.stForm.TemplateID#
            AND PG_Group_Type = 2
            AND Group_Level_ID = #qGetTopLevelGroups.Distributor_Group_Level_ID#
            AND Active = 1
            AND Deleted = 0
       </cfquery>
       <cfset errorCount = errorCount + 1 />
       <cfset addedVal = ListAppend(addedVal, qGetTopLevelGroups.Group_Level_Desc) />
       <cfset returnVal = returnVal & errorCount & ". #qGetTopLevelGroups.Group_Level_Desc#" & "\n"  />
       </cfif>


    </cfloop> <!--- qGetTopLevelGroups --->
   <!---
     TODO:
     INSERT INTO THE Group_Template table, values for the current template
     if product_level_id already exists then update the 3 check boxes alone
     if the Product_level_ID does not exist insert a new record.
     if it exists in the table and removed in the page then
     set the flag to deleted.
   --->
    <cfif (errorCount EQ 1)>
      <cfset returnVal = "The following Allow Filter was unchecked as no filter items were selected:\n\n #returnVal# \n" />
    <cfelseif (errorCount GT 1)>
      <cfset returnVal = "The following Allow Filter were unchecked as no filter items were selected:\n\n #returnVal# \n" />
    </cfif>
    <cfreturn returnVal />
  </cffunction>

<!--- Save function for Operator Template --->

   <cffunction name="fnSaveFilterOperators" access="public" returntype="string">
    <cfargument name="UserID" required="true" type="string"  />
    <cfargument name="stForm" required="true" type="any" default="" />
    <cfset OprGroupDataManager = CreateObject("component", "components.operator.Group.DataManager").init() />
   <!---  <cfset GroupDataManager = CreateObject("component", "components.operator.Group.DataManager") /> --->
    <cfset PGManager = CreateObject("component", "components.settings.PlanningGroups.PlanningGroupsManager").init() />

    <cfset errorCount = 0 />
    <cfset returnVal = "" />
    <cfset addedVal = "" />
    <cfset FilterValsChecked="" />


   <!---  <cfset qGetTopLevelGroups = GroupDataManager.getProductGroupsData() /> --->
    <cfquery name="qryOprList" datasource="#application.datasource#">
       SELECT DISTINCT(Operator_Group_Level_ID) FROM Operator_Group_Level WHERE Active= 1 AND Deleted = 0
    </cfquery>
   <cfset qGetTopLevelGroups = OprGroupDataManager.getOperatorLevelsFilter(1, "#ValueList(qryOprList.Operator_Group_Level_ID)#", "") />

    <cfset qryGetGroupTemplateByTemplateID = PGManager.fnGetGroupTemplateByTemplateID(arguments.stForm.TemplateID,arguments.stForm.oprPGGroupType)/>
      <cfloop query="qGetTopLevelGroups">
        <cfset oprGroupExistsAlready = 0 />
          <cfquery name="qryCheckCGTS" datasource="#application.datasource#">
            SELECT  Operator_Group_Template_Selection_ID
            FROM Operator_Group_Template_Selection
            WHERE Operator_Group_Level_ID = #qGetTopLevelGroups.Operator_Group_Level_ID#
            AND Template_ID = #arguments.stForm.TemplateID#
            AND Active = 1
            AND Deleted = 0
          </cfquery>
        <cfloop query="qryGetGroupTemplateByTemplateID">

          <cfif qryGetGroupTemplateByTemplateID.Group_Level_ID EQ qGetTopLevelGroups.Operator_Group_Level_ID>
            <cfset oprGroupExistsAlready = 1 />
          </cfif>
         <cfif oprGroupExistsAlready EQ 1>
          <cfset SearchChecked = "0" />
          <cfset GroupChecked = "0" />
          <cfset FiltersChecked = "0" />
         <cfloop index="colName" list="#arguments.stForm.fieldnames#">

            <cfif (FindNoCase("CHKBOXSEARCHOPR_#qryGetGroupTemplateByTemplateID.Group_Level_ID#_",colName) NEQ 0)>
              <cfset SearchChecked = "1" />
              <cfset temp2 = StructDelete(arguments.stForm, colName) />
            </cfif>
            <cfif (FindNoCase("CHKBOXGROUPOPR_#qryGetGroupTemplateByTemplateID.Group_Level_ID#_",colName) NEQ 0)>
              <cfset GroupChecked = "1" />
              <cfset temp2 = StructDelete(arguments.stForm, colName) />
            </cfif>
            <cfif (FindNoCase("CHKBOXFILTERSOPR_#qryGetGroupTemplateByTemplateID.Group_Level_ID#_",colName) NEQ 0)>
             <cfset FiltersChecked = "1" />
             <cfset FilterValsChecked = Listappend(FilterValsChecked,qryGetGroupTemplateByTemplateID.Group_Level_ID) />
             <!---  <cfif qryCheckCGTS.RecordCount GTE 1>
                <cfset FiltersChecked = "1" />
              <cfelse>
                <cfset FiltersChecked = "0" />
                <cfset errorCount = errorCount + 1 />

                <cfif (ListFindNoCase(addedVal,qGetTopLevelGroups.Group_Level_Desc) EQ 0)>
                  <cfset addedVal = ListAppend(addedVal, qGetTopLevelGroups.Group_Level_Desc) />
                  <cfset returnVal =  "#qGetTopLevelGroups.Group_Level_Desc#" & "\n" & returnVal />
                </cfif>
              </cfif>  ---><!---   <cfif qryCheckCGTS.RecordCount GTE 1> --->

              <cfset temp2 = StructDelete(arguments.stForm, colName) />
            </cfif>
          </cfloop>  <!--- End Loop colname, Fieldnames --->
          <!--- EXISTING FIELD UPDATE --->
          <!---  <cfif  SearchChecked EQ "0" AND  GroupChecked EQ "0" AND FiltersChecked EQ "0">
              Active = 0,
              Deleted = 1,
          </cfif> --->
          <cfquery name="updGroupTemplate" datasource="#application.datasource#">
            UPDATE Group_Template
            SET
              Allow_In_Search = #SearchChecked#,
              Allow_In_Group_Search = #GroupChecked#,
              Allow_Filter = #FiltersChecked#,

              Updated_Date = GetDate(),
              Updated_By =  '#arguments.UserID#',
              Updated_From = 'Template Page - Operator Filter'

            WHERE Group_Template_ID = #qryGetGroupTemplateByTemplateID.Group_Template_ID#
          </cfquery>
          <cfif FiltersChecked EQ "0">
           <cfquery name="updOprGroupSelection" datasource="#application.datasource#">
            UPDATE Operator_Group_Template_Selection
            SET Active = 0,
            Deleted = 1,
            Updated_Date = GetDate(),
            Updated_By =  '#arguments.UserID#'
            WHERE
                  Template_ID = #arguments.stForm.TemplateID#
            AND   Operator_Group_Level_ID = #qryGetGroupTemplateByTemplateID.Group_Level_ID#
           </cfquery>
          </cfif>
          </cfif> <!--- oprGroupExistsAlready EQ 1 --->
        </cfloop> <!--- End Loop query="qryGetGroupTemplateByTemplateID" --->

      <cfif oprGroupExistsAlready EQ 0>
      <!--- Check for the existance of this record in the FORM scope and do an insert as it does not exists currently --->
          <cfset SearchChecked = "0" />
          <cfset GroupChecked = "0" />
          <cfset FiltersChecked = "0" />
          <cfloop index="colName" list="#arguments.stForm.fieldnames#">
            <cfif (FindNoCase("CHKBOXSEARCHOPR_#qGetTopLevelGroups.Operator_Group_Level_ID#_",colName) NEQ 0)>
              <cfset SearchChecked = "1" />
              <cfset temp2 = StructDelete(arguments.stForm, colName) />
            </cfif>
            <cfif (FindNoCase("CHKBOXGROUPOPR_#qGetTopLevelGroups.Operator_Group_Level_ID#_",colName) NEQ 0)>
              <cfset GroupChecked = "1" />
              <cfset temp2 = StructDelete(arguments.stForm, colName) />
            </cfif>
            <cfif (FindNoCase("CHKBOXFILTERSOPR_#qGetTopLevelGroups.Operator_Group_Level_ID#_",colName) NEQ 0)>
              <cfset FiltersChecked = "1" />
              <cfset FilterValsChecked = Listappend(FilterValsChecked,qryGetGroupTemplateByTemplateID.Group_Level_ID) />
              <cfset temp2 = StructDelete(arguments.stForm, colName) />
            </cfif>
          </cfloop>
           <cfif  SearchChecked EQ "1" OR GroupChecked EQ "1" OR FiltersChecked EQ "1">
            <cfquery name="qryChkISPG" datasource="#application.datasource#">
                SELECT TOP 1 IS_PG  FROM
                Operator_group_level
                WHERE Operator_Group_Level_ID = #qGetTopLevelGroups.Operator_Group_Level_ID#
            </cfquery>
            <cfif qryCheckCGTS.RecordCount EQ 0>
              <cfset FiltersChecked = 0 />
            </cfif>
            <cfquery name="qInsPGTypeTemplate" datasource="#application.datasource#">
            INSERT INTO Group_Template
            ( Template_ID,
              Group_Level_ID,
              PG_Group_Type,
              Allow_in_Search,
              Allow_in_Group_Search,
              Allow_Filter,
              Active,
              Deleted,
              Created_Date,
              Created_By,
              PG_Flag,
              Updated_From)
            VALUES
             (#arguments.stForm.TemplateID#,
              #qGetTopLevelGroups.Operator_Group_Level_ID#,
              #arguments.stForm.oprPGGroupType#,
              #SearchChecked#,
              #GroupChecked#,
              #FiltersChecked#,
              <cfqueryparam value="1" cfsqltype="cf_sql_int"/>,
              <cfqueryparam value="0" cfsqltype="cf_sql_int"/>,
              GetDate(),
              <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>,
              <cfif ((qryChkISPG.RecordCount EQ 1) AND (qryChkISPG.IS_PG EQ 1))>1<cfelse>0</cfif>,
              <cfqueryparam value="Template Page - Operator Filter" cfsqltype="cf_sql_varchar"/>
              )
          </cfquery>

           </cfif><!--- if SearchChecked EQ "1" OR GroupChecked EQ "1" OR FiltersChecked EQ "1" --->
      </cfif><!---  <cfif prodGroupExistsAlready EQ 0> --->
  <cfif (qryCheckCGTS.RecordCount EQ 0 AND ListFindNoCase(FilterValsChecked,qGetTopLevelGroups.Operator_Group_Level_ID) GTE 1)>

       <cfquery name="updGroupTemplateFilters" datasource="#application.datasource#">
            UPDATE Group_Template
            SET  Allow_Filter = 0,
                 Updated_Date = GetDate(),
                 Updated_By =  '#arguments.UserID#',
								 Updated_From = 'Program Wizard - Template Filters page'
            WHERE Template_ID = #arguments.stForm.TemplateID#
            AND PG_Group_Type = 3
            AND Group_Level_ID = #qGetTopLevelGroups.Operator_Group_Level_ID#
            AND Active = 1
            AND Deleted = 0
       </cfquery>
       <cfset errorCount = errorCount + 1 />
        <cfset addedVal = ListAppend(addedVal, qGetTopLevelGroups.Group_Level_Desc) />
        <cfset returnVal = returnVal & errorCount & ". #qGetTopLevelGroups.Group_Level_Desc#" & "\n"  />
       </cfif>


    </cfloop> <!--- qGetTopLevelGroups --->
   <!---
     TODO:
     INSERT INTO THE Group_Template table, values for the current template
     if product_level_id already exists then update the 3 check boxes alone
     if the Product_level_ID does not exist insert a new record.
     if it exists in the table and removed in the page then
     set the flag to deleted.
   --->
    <cfif (errorCount EQ 1)>
      <cfset returnVal = "The following Allow Filter was unchecked as no filter items were selected:\n\n #returnVal# \n" />
    <cfelseif (errorCount GT 1)>
      <cfset returnVal = "The following Allow Filter were unchecked as no filter items were selected:\n\n #returnVal# \n" />
    </cfif>

   <cfreturn returnVal />
  </cffunction>

<!--- D29929: Dashboard Settings --->
   <cffunction name="SaveDashboardAccess" access="public" returntype="void" >

   	 	<cfargument name="budget"   	required="true">
		<cfargument name="billback" 	required="true">
		<cfargument name="sales"    	required="true">
		<cfargument name="Performance" 	required="true">

		<cfargument name="profileID" 	required="true">

		<cfargument name="Budgets_territory_total" 	required="true">
		<cfargument name="Budgets_customer_specific_budgets" 	required="true">
		<cfargument name="Budgets_program_details" 	required="true">
		<cfargument name="Budgets_territory_budget_level_detail" 	required="true">
		<cfargument name="Budgets_sub_region_budget_level_detail" 	required="true">

		<cfargument name="Billbacks_summary_table" 	required="true">
		<cfargument name="Billbacks_monthly_summary" 	required="true">
		<cfargument name="Billbacks_yearly_summary" 	required="true">
		<cfargument name="Billbacks_quarterly_summary" 	required="true">
		<cfargument name="Billbacks_stats" 	required="true">

		<cfargument name="Sales_last_12_months_eqc" 	required="true">
		<cfargument name="Sales_fiscal_year_summary_eqc" 	required="true">
		<cfargument name="Sales_sales_view_drilldown" 	required="true">
		<cfargument name="Sales_TBM_sales_tracker" 	required="true">
		<cfargument name="Sales_NAM_sales_tracker" 	required="true">
		<cfargument name="Sales_tracker" 	required="true">

		<cfargument name="Performance_programs" 	required="true">

		<cfset useLakebaseForqDashboardAccessInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dashboard_access")>
<cfif useLakebaseForqDashboardAccessInfo>
	<cftry>
		<cfset qDashboardAccessInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dashboard_access", {
				"profile_id" = "eq.#arguments.profileID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqDashboardAccessInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDashboardAccessInfo>
<cfquery name="qDashboardAccessInfo" datasource="#application.datasource#">
			SELECT *
			FROM Dashboard_Access
			WHERE Profile_ID = #arguments.profileID#
		</cfquery>
</cfif>
		<cfif qDashboardAccessInfo.Recordcount>
				  <cfquery name="qDashboardAccess"  datasource="#application.datasource#">
				  	UPDATE	Dashboard_Access

					SET		budget 									=	#arguments.budget#,
							billback 								=	#arguments.billback#,
							sales 									=	#arguments.sales#,


							Budgets_territory_total					=	#arguments.Budgets_territory_total#,
							Budgets_customer_specific_budgets		=	#arguments.Budgets_customer_specific_budgets#,
							Budgets_program_details					=	#arguments.Budgets_program_details#,
							Budgets_territory_budget_level_detail	=	#arguments.Budgets_territory_budget_level_detail#,
							Budgets_sub_region_budget_level_detail	=	#arguments.Budgets_sub_region_budget_level_detail#,

							Billbacks_summary_table					=	#arguments.Billbacks_summary_table#,
							Billbacks_monthly_summary				=	#arguments.Billbacks_monthly_summary#,
							Billbacks_yearly_summary				=	#arguments.Billbacks_yearly_summary#,
							Billbacks_quarterly_summary				=	#arguments.Billbacks_quarterly_summary#,
							Billbacks_stats							=	#arguments.Billbacks_stats#,

							Sales_last_12_months_eqc				=	#arguments.Sales_last_12_months_eqc#,
							Sales_fiscal_year_summary_eqc			=	#arguments.Sales_fiscal_year_summary_eqc#,
							Sales_sales_view_drilldown				=	#arguments.Sales_sales_view_drilldown#,
							Sales_TBM_sales_tracker					=	#arguments.Sales_TBM_sales_tracker#,
							Sales_NAM_sales_tracker					=	#arguments.Sales_NAM_sales_tracker#,
							Sales_tracker							=	#arguments.Sales_tracker#,

							Performance								=	#arguments.Performance#,
							Performance_programs					=	#arguments.Performance_programs#

					WHERE	Profile_ID 								=	#arguments.profileID#
				  </cfquery>
		<cfelse>
			   	   <cfquery name="qDashboardAccess" datasource="#application.datasource#">

					 INSERT INTO Dashboard_Access
					 	(
					 		budget,
					 		billback,
					 		sales,
					 		Profile_ID,

					 		Budgets_territory_total,
					 		Budgets_customer_specific_budgets,
					 		Budgets_program_details,
					 		Budgets_territory_budget_level_detail,
					 		Budgets_sub_region_budget_level_detail,

					 		Billbacks_summary_table,
					 		Billbacks_monthly_summary,
					 		Billbacks_yearly_summary,
					 		Billbacks_quarterly_summary,
					 		Billbacks_stats,

					 		Sales_last_12_months_eqc,
					 		Sales_fiscal_year_summary_eqc,
					 		Sales_sales_view_drilldown,
					 		Sales_TBM_sales_tracker,
					 		Sales_NAM_sales_tracker,
					 		Sales_tracker

					 	)

					 VALUES
					 	(
					 		#arguments.budget#,
					 		#arguments.billback#,
					 		#arguments.sales#,
					 		#arguments.profileID#,

					 		#arguments.Budgets_territory_total#,
					 		#arguments.Budgets_customer_specific_budgets#,
					 		#arguments.Budgets_program_details#,
					 		#arguments.Budgets_territory_budget_level_detail#,
					 		#arguments.Budgets_sub_region_budget_level_detail#,

					 		#arguments.Billbacks_summary_table#,
					 		#arguments.Billbacks_monthly_summary#,
					 		#arguments.Billbacks_yearly_summary#,
					 		#arguments.Billbacks_quarterly_summary#,
					 		#arguments.Billbacks_stats#,

					 		#arguments.Sales_last_12_months_eqc#,
					 		#arguments.Sales_fiscal_year_summary_eqc#,
					 		#arguments.Sales_sales_view_drilldown#,
					 		#arguments.Sales_TBM_sales_tracker#,
					 		#arguments.Sales_NAM_sales_tracker#,
					 		#arguments.Sales_tracker#

					 	)

				   </cfquery>
		</cfif>
   </cffunction>
<!--- D29929: Dashboard Settings --->

<!---D36607--->
   <cffunction name="EZratesExcel" access="public" returntype="query" >
   	 	<cfargument name="templateID"   	required="true" type="numeric">
			<cfquery name="qEZratesExcel" datasource="#application.datasource#">
						select	PCPO.Created_Type,
								case when contract_products.Is_Group = 1 or contract_products.Captured_From_Group = 1 then grp.Group_Number else 'N/A' end as Group_ID,
								case when contract_products.Is_Group = 1 or contract_products.Captured_From_Group = 1 then grp.Group_Desc else 'N/A' end as Group_Desc,
								case when contract_products.Is_Group = 1
								then
								CASE WHEN grp.Group_Number IS NULL THEN 'N/A' ELSE grp.Group_Number END
								else
								CASE WHEN bsa_foodservice_items_master.item IS NULL THEN 'N/A' ELSE bsa_foodservice_items_master.item END
								end as Item_ID,
								case when contract_products.Is_Group = 1 then grp.Group_Desc else bsa_foodservice_items_master.description end as Item_Desc,
								program_rebates_component_data.rate,
								uom.Abbreviation
						from	Program_Control_Panel_Options PCPO
						inner join program_rebates_component
						on	program_rebates_component.deleted = 0
						and	program_rebates_component.program_id = PCPO.EZ_Contract_Id
						inner join program_rebates_component_name
						on	program_rebates_component_name.program_rebates_component_name_id = program_rebates_component.program_rebates_component_name_id
						inner join contract_products
						on	contract_products.deleted = 0
						and	contract_products.contract_main_id = program_rebates_component.program_id
						and	contract_products.product_type_id = 2
						inner join bsa_foodservice_items_master
						on	bsa_foodservice_items_master.bsa_foodservice_items_master_id = contract_products.bsa_foodservice_items_master_id
						inner join program_rebates_product_data
						on	program_rebates_product_data.deleted = 0
						and	program_rebates_product_data.contract_products_id = contract_products.contract_products_id
						inner join program_rebates_component_data
						on	program_rebates_component_data.deleted = 0
						and	program_rebates_component_data.program_rebates_component_id = program_rebates_component.program_rebates_component_id
						and	program_rebates_component_data.program_rebates_product_data_id = program_rebates_product_data.program_rebates_product_data_id
						inner join Units_of_Measure uom
						on		uom.Unit_Of_Measure_ID = program_rebates_component_data.Unit_Of_Measure_ID
						left join All_Product_Group_Types grp
						on	(
								(contract_products.Is_Group = 1 and grp.Group_GUID = contract_products.bsa_foodservice_items_master_id)
								or
								(contract_products.Captured_From_Group = 1 and cast(grp.Group_GUID as nvarchar(50)) = contract_products.Product_Group_ID)
							)
						where	PCPO.ProgramControl_Panel_Options_ID = #arguments.templateID#
						order by case when contract_products.Is_Group = 1 or contract_products.Captured_From_Group = 1 then grp.Group_Number else 'N/A' end,
								bsa_foodservice_items_master.item
			 </cfquery>
	<cfreturn qEZratesExcel/>
	</cffunction>
<!---D36607--->

   <cffunction name="EZRatesSettingExcel" access="public" returntype="query" >
   	 	<cfargument name="EZButtonRateID"   	required="true" type="numeric">
			<cfquery name="qEZratesExcel" datasource="#application.datasource#">
				select	EZBRS.EZ_Button_Rate_Title,
								case when contract_products.Is_Group = 1 or contract_products.Captured_From_Group = 1 then grp.Group_Number else 'N/A' end as Group_ID,
								case when contract_products.Is_Group = 1 or contract_products.Captured_From_Group = 1 then grp.Group_Desc else 'N/A' end as Group_Desc,
								case when contract_products.Is_Group = 1
								then
								CASE WHEN grp.Group_Number IS NULL THEN 'N/A' ELSE grp.Group_Number END
								else
								CASE WHEN bsa_foodservice_items_master.item IS NULL THEN 'N/A' ELSE bsa_foodservice_items_master.item END
								end as Item_ID,
								case when contract_products.Is_Group = 1 then grp.Group_Desc else bsa_foodservice_items_master.description end as Item_Desc,
								program_rebates_component_data.rate,
								uom.Abbreviation
						FROM EZ_Button_Rate_Setting EZBRS
						-- Program_Control_Panel_Options PCPO
						LEFT join program_rebates_component
						on	program_rebates_component.deleted = 0
						and	program_rebates_component.program_id = EZBRS.EZ_Contract_Id
						LEFT join program_rebates_component_name
						on	program_rebates_component_name.program_rebates_component_name_id = program_rebates_component.program_rebates_component_name_id
						LEFT join contract_products
						on	contract_products.deleted = 0
						and	contract_products.contract_main_id = program_rebates_component.program_id
						and	contract_products.product_type_id = 2
						LEFT join bsa_foodservice_items_master
						on	bsa_foodservice_items_master.bsa_foodservice_items_master_id = contract_products.bsa_foodservice_items_master_id
						LEFT join program_rebates_product_data
						on	program_rebates_product_data.deleted = 0
						and	program_rebates_product_data.contract_products_id = contract_products.contract_products_id
						LEFT join program_rebates_component_data
						on	program_rebates_component_data.deleted = 0
						and	program_rebates_component_data.program_rebates_component_id = program_rebates_component.program_rebates_component_id
						and	program_rebates_component_data.program_rebates_product_data_id = program_rebates_product_data.program_rebates_product_data_id
						LEFT join Units_of_Measure uom
						on		uom.Unit_Of_Measure_ID = program_rebates_component_data.Unit_Of_Measure_ID
						left join All_Product_Group_Types grp
						on	(
								(contract_products.Is_Group = 1 and grp.Group_GUID = contract_products.bsa_foodservice_items_master_id)
								or
								(contract_products.Captured_From_Group = 1 and cast(grp.Group_GUID as nvarchar(50)) = contract_products.Product_Group_ID)
							)
						where	EZBRS.EZ_Button_Rate_ID = #arguments.EZButtonRateID#
						order by case when contract_products.Is_Group = 1 or contract_products.Captured_From_Group = 1 then grp.Group_Number else 'N/A' end,
								bsa_foodservice_items_master.item
				</cfquery>
	<cfreturn qEZratesExcel/>
	</cffunction>

	<cffunction name="getGenericType" access="public" returntype="query">
		<cfset useLakebaseForqGenericType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("generic_type")>
<cfif useLakebaseForqGenericType>
	<cftry>
		<cfset qGenericType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("generic_type", {
				"select" = "generic_type,generic_type_id"
			}), "generic_type,generic_type_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGenericType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGenericType>
<cfquery name="qGenericType" datasource="#application.datasource#">
			select Generic_Type, Generic_Type_ID
			from Generic_Type
		</cfquery>
</cfif>
		<cfreturn qGenericType/>
	</cffunction>

	<cffunction name="getDiscountComponentDefaultPaidTo" output="false" returntype="query">
		<cfargument name="templateID" 	type="Numeric" required="true" />
		<cfargument name="discountTypeID" type="Numeric" required="true" />
		<cfargument name="componentNameID" 	type="Numeric" required="true" />

		<cfset useLakebaseForqGetDiscountComponentDefaultPaidTo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_template_component")>
<cfif useLakebaseForqGetDiscountComponentDefaultPaidTo>
	<cftry>
		<cfset qGetDiscountComponentDefaultPaidTo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_template_component", {
				"template_id" = "eq.#arguments.templateID#",
				"discount_type_id" = "eq.#arguments.discountTypeID#",
				"component_id" = "eq.#arguments.componentNameID#",
				"deleted" = "eq.0",
				"select" = "default_paid_to_cf_pages"
			}), "default_paid_to_cf_pages"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDiscountComponentDefaultPaidTo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDiscountComponentDefaultPaidTo>
<cfquery name="qGetDiscountComponentDefaultPaidTo" datasource="#application.datasource#">
		SELECT Default_Paid_To_CF_Pages
		FROM Program_Template_Component
		WHERE Template_ID = '#arguments.templateID#'
		AND Discount_Type_ID = '#arguments.discountTypeID#'
		AND Program_Template_Component.Component_ID = '#arguments.componentNameID#'
		AND Deleted = 0
		</cfquery>
</cfif>

		<cfreturn qGetDiscountComponentDefaultPaidTo />
	</cffunction>

	<cffunction name="getTemplatePaidToStruct" output="false" returntype="struct">
		<cfargument name="form_scope" type="struct" required="true" />

		<cfset structTemplatePaidTo = structNew()>

		<cfset loopInt = 0>
		<cfloop collection="#arguments.form_scope#" item="fieldObj">
			<!--- If the form field is "paid to distributor", "paid to operator" etc, set the "Template_Paid_To_Select_XXXX" form field value
			in "Template_paidto" format.
			Eg:
			When "Template_PAID_TO_SELECT_1_1" has value of  4  and Template_PAID_TO_SELECT_1_2 also has value of of 4.
			On "TEMPLATE_PAID_TO_SELECT_1_1", the first 1 is discount type (fixed price has id of 1), the second 1 is the "Paid to",
			1 being paid to (distributor has id of 1). The value of 4 is templateID.
			Below code will make a struct which will have 2 entries 4_1 and 4_2. This is the combination of template and paid to.
			--->
			<cfif FindNoCase('Template_Paid_To_Select',fieldObj) neq 0>
				<cfset loopInt = loopInt + 1>
				<cfset InnerloopInt =0>
				<cfloop list="#arguments.form_scope[fieldObj]#" index="templateID">
				<cfset InnerloopInt = InnerloopInt + 1>
					<cfset structTemplatePaidTo[loopInt][InnerloopInt] = templateID & "_" & ListLast(fieldObj,'_')>
				</cfloop>
			</cfif>
		</cfloop>

		<cfreturn structTemplatePaidTo />
	</cffunction>

	<!--- get the number of components for a template and discount tyoe combination. --->
	<cffunction name="getCompCountForTemplateAndDiscountType" output="false" returntype="numeric">
		<cfargument name="templateId" required="true" type="numeric" />
		<cfargument name="discountTypeID" type="numeric" required="true" />

		<cfset var compCount = 0>

		<cfquery name="qgetCompCountForTemplateAndDiscountType" datasource="#application.datasource#">
		SELECT COUNT(ptc.Program_Template_Component_ID) As NumberOfComponents
		FROM Program_Template_Component ptc
		INNER JOIN Program_Control_Panel_Options pcpo
		ON ptc.Template_ID = pcpo.ProgramControl_Panel_Options_ID
		WHERE ptc.Template_ID = <cfqueryparam value="#arguments.templateId#" cfsqltype="CF_SQL_INTEGER">
		AND ptc.deleted = 0
		AND ptc.Discount_Type_ID = <cfqueryparam value="#arguments.discountTypeID#" cfsqltype="CF_SQL_INTEGER">
		<!--- Where only a single component per discount type, is allowed  on a template --->
		AND pcpo.Single_Component_Per_Discount_Type = 1
		</cfquery>

		<cfset compCount = qgetCompCountForTemplateAndDiscountType.NumberOfComponents>

		<cfreturn compCount />
	</cffunction>


	<cffunction name="getTemplateProgramPlanner" output="false" returntype="query">
		<cfargument name="templateId" required="true" type="numeric" />

		<cfquery name="qTemplateProgramPlanner" datasource="#application.datasource#">
			SELECT TPS.*, _Users.Name_First, _Users.Name_Last
			FROM   Template_Planner_Settings TPS
				   LEFT JOIN _Users ON
					TPS.Updated_By = _Users.User_ID
					INNER JOIN Program_Control_Panel_Options PCPO
							ON	PCPO.First_Parent_ID = TPS.First_Parent_ID
							AND PCPO.IsDominant = 1
			WHERE	 PCPO.ProgramControl_Panel_Options_ID = <cfqueryparam value="#arguments.templateId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfreturn qTemplateProgramPlanner>
	</cffunction>


	<cffunction name="getRetailPlannerTemplates" output="false" returntype="query">

		<cfargument name="templateId" required="true" type="numeric" />

		<cfquery name="qGetRetailPlannerTemplates" datasource="#application.datasource#">

			SELECT	ProgramControl_Panel_Options_ID as Template_ID,
					Active,
					Generic_Type,
					Created_Type,
					Program_Control_Panel_Options.First_Parent_ID,
					Template_Parent_ID,
					Retail_Planner,
					ISNULL(Planner_Program_Templates.Planner_Template_Id, 0) as Component_Selected
			FROM	Program_Control_Panel_Options
					LEFT JOIN Planner_Program_Templates on Planner_Program_Templates.First_Parent_Id = Program_Control_Panel_Options.First_Parent_ID
					AND Planner_Program_Templates.Planner_Template_Id = '#arguments.templateId#'
					AND	Planner_Program_Templates.Deleted = 0
			WHERE 	Program_Control_Panel_Options.Deleted = 0
			AND 	IsDominant = 1
			AND		Retail_Planner = 1
 			ORDER BY Generic_Type
		</cfquery>

		<cfreturn qGetRetailPlannerTemplates>

	</cffunction>


</cfcomponent>