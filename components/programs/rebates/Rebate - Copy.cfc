<!---
	Description:
		Base component for a program rebate

--->

<cfcomponent displayname="Rebate" hint="Component used to handle program component rebates." >

	<cfproperty name="tmpFilePath" type="string" hint="A path to the file holding the WDDX data structure.">

	<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
	<cfset this.GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />
	<!--- get install path --->
	<!--- 	<cfset useLakebaseForgetInstallationPath = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForgetInstallationPath>
	<cftry>
		<cfset getInstallationPath = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "application_installation_root_location"
			}), "application_installation_root_location"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetInstallationPath = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetInstallationPath>
<CFQUERY NAME="getInstallationPath" datasource="#application.datasource#" cachedwithin="#CreateTimeSpan(0,6,0,0)#">
		SELECT Application_Installation_Root_Location
		FROM General_Settings
	</CFQUERY>
</cfif> --->

	<!---set the temp file path to the app install path--->
	<!--- <cfset this.tmpFilePath = getInstallationPath.Application_Installation_Root_Location & "\Temp_Files\Rebates"/> --->
	<cfif isDefined("request.app_general_functions")>
		<cfset this.tmpFilePath = request.app_general_functions.Get_Document_Path() & "\Temp_Files\Rebates"/>
	</cfif>

	<!--- Constructor --->
	<cfscript>
		this.stRebate = StructNew();
		this.stRebate.programID = "";
		this.stRebate.aProd = ArrayNew(1);
		this.stRebate.aComp = ArrayNew(1);
		this.stRebate.aCompVal = ArrayNew(2);
		initialiseGroupLevel();
		this.displayRecords = this.getMaxProducts();
		this.appsettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
	</cfscript>
	<!--- /Constructor --->
	<!---function called to initialize rebate--->
	<cffunction name="init" output="false" displayname="init" hint="Method used to initialize a rebate component.">

		<cfargument name="programID" type="numeric" required="true" default="" displayname="Program ID" hint="The unique id of the program." />
		<cfargument name="fileName" type="string" required="true" default="" displayname="File Name" hint="Name of the file that will store the WDDX data structure." />
		<cfargument name="displaygrouptype" type="numeric" required="false" default="0" />
		<!---try and load rebate on init, if we don't have one then we'll just get an empty data structure--->
		<cfscript>
			rebate = createObject("component","components.programs.rebates.Rebate");
			rebateData = rebate.loadFromDB(programID=arguments.programID,displayGroupType=arguments.displaygrouptype,useXML=0);
			//rebate.updateWddxDataFile(rebateData,arguments.fileName);
		</cfscript>

	</cffunction>
	<!---load a rebate and return all data wrapped up in a struct--->
	<cffunction name="loadFromDB" output="false" returntype="struct" displayname="Load rebate from database" hint="This method will load all rebate data from the database.">

		<cfargument name="programID" type="string" required="true" default="" />
		<cfargument name="contractProdId" type="numeric" required="false" default="-0" displayname="Contract Product ID" hint="The Product ID if loading by one product at a time." />
		<cfargument name="itemMasterId" type="string" required="false" default="0" />
		<cfargument name="displayGroupType" type="numeric" required="false" default="0" />
		<cfargument name="IsDateExclusion" type="boolean" required="false" default="0" />
		<cfargument name="checktemplatesettings" type="boolean" required="false" default="0" />
		<cfargument name="groupfieldname" type="string" required="false" default="" />
		<cfargument name="template_id" type="numeric" required="false" default="0" />
		<cfargument name="CheckForActiveProductsOnly" type="boolean" required="false" default="0" /> <!--- Dev Note: KAL; 8362 --->
		<cfargument name="EZTemplate" type="boolean" required="false" default="0" />
		<cfargument name="EZButton_On" type="boolean" required="false" default="0" />
		<cfargument name="Copy_Revise" type="boolean" required="false" default="0" />
		<cfargument name="RevisionOfExistingContract" type="boolean" required="false" default="0" /><!--- this argument used below to do the class code restriction logic, so do not reuse this argument for other purpose --->
		<cfargument name="ClassCodeUserID" type="string" required="false" default=""/><!--- only use this argument from copy/revise, not from inside a program, above argument RevisionOfExistingContract relies on this argument, see more details below --->
		<cfargument name="EZOriginalProgramID" type="numeric" required="false" default="0" hint="to be used only while copying an ez button program, to apply the ez button rules" />
		<cfargument name="useXML" type="numeric" required="false" default="0" />
		<cfargument name="compUUID" type="string" required="false" default="#CreateUUID()#" />
		<cfset var local = structNew() />

      <cfquery name="GetContractInfo" datasource="#application.datasource#">
    		SELECT Contract_Main.*,Contract_Main_Aux_Data.Price_List_ID
    		FROM Contract_Main
			INNER JOIN Contract_Main_Aux_Data
			ON Contract_Main.Contract_Main_ID = Contract_Main_Aux_Data.Contract_Main_ID
    		WHERE Contract_Main.Contract_Main_ID = '#arguments.programID#'
  	  </cfquery>

      <cfset useLakebaseForGetTemplateInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForGetTemplateInfo>
	<cftry>
		<cfset GetTemplateInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#GetContractInfo.ProgramType_ID#",
				"select" = "first_parent_id,single_component_per_discount_type"
			}), "first_parent_id,single_component_per_discount_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetTemplateInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetTemplateInfo>
<cfquery name="GetTemplateInfo" datasource="#application.datasource#">
    		SELECT 	First_parent_ID,
					Single_Component_Per_Discount_Type
        	FROM Program_Control_Panel_Options
        	WHERE ProgramControl_Panel_Options_ID = #GetContractInfo.ProgramType_ID#
      </cfquery>
</cfif>

		<!--- Dev Note: KAL; 8575 --->
		<cfif IsDateExclusion eq 1
			OR arguments.checktemplatesettings EQ 1
			OR CheckForActiveProductsOnly EQ 1
			OR NOT FileExists("#request.app_general_functions.Get_Document_Path()#\data_Files\created\contracts\RebateData\#arguments.programID#.xml")
			OR arguments.EZButton_On EQ 1
			OR useXML EQ 0 >

			<cfscript>
				product = createObject("component","components.programs.rebates.Product");
				comp = createObject("component","components.programs.rebates.RebateComponent");
				rate = createObject("component","components.programs.rebates.RebateComponentRate");
				GroupDataManager = CreateObject("component","components.products.Group.DataManager");
				local.bidRequestProdMan = CreateObject("component", "components.programs.bid_request.BidRequestProductManager");
			</cfscript>
			<cfscript>
				this.stRebate = StructNew();
				this.stRebate.programID = "";
				this.stRebate.aProd = ArrayNew(1);
				this.stRebate.aComp = ArrayNew(1);
				this.stRebate.aCompVal = ArrayNew(2);
				initialiseGroupLevel();
			</cfscript>
      <cfset bDiscountRebateMaxRateOn = 0 />
			<cfif isdefined("arguments.template_id") and arguments.template_id NEQ 0>
				<cfset useLakebaseForqGettemplatesettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForqGettemplatesettings>
	<cftry>
		<cfset qGettemplatesettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#arguments.template_id#",
				"select" = "discount_rebates_item_level,discount_rebates_group_level,ezbutton_update_with_latest_template_settings_on_revise,ez_contract_id,discount_rebate_max_rate_on,ezbutton_enter_beyond_max_rates,ezbutton_default_show_item_rates"
			}), "discount_rebates_item_level,discount_rebates_group_level,ezbutton_update_with_latest_template_settings_on_revise,ez_contract_id,discount_rebate_max_rate_on,ezbutton_enter_beyond_max_rates,ezbutton_default_show_item_rates"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGettemplatesettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGettemplatesettings>
<cfquery name="qGettemplatesettings" datasource="#application.datasource#">
					SELECT Discount_Rebates_Item_Level,
								 Discount_Rebates_group_Level,
								 EzButton_Update_With_Latest_Template_Settings_On_Revise,
								 Ez_Contract_ID,
          			 			 Discount_Rebate_Max_Rate_On,
								 EzButton_Enter_Beyond_Max_Rates,
								 EzButton_Default_Show_Item_Rates
					FROM
								 Program_Control_Panel_Options
					WHERE  ProgramControl_Panel_Options_ID = #arguments.template_id#
				</cfquery>
</cfif>
        <cfset bDiscountRebateMaxRateOn = qGettemplatesettings.Discount_Rebate_Max_Rate_On />

       <!---  <cfif (isDefined("arguments.RevisionOfExistingContract") AND arguments.RevisionOfExistingContract EQ 1)>
          <cfif (qGettemplatesettings.RecordCount GT 0)>
            <cfif (qGettemplatesettings.EzButton_Update_With_Latest_Template_Settings_On_Revise EQ 1)> --->
              <!---
                  Set the programID to be the program id of the latest template
                  so that we can grab all the components and programs from the
                  template if the EzButton_Update_With_Latest_Template_Settings_On_Revise
                  setting is set to 1.
              --->
              <!--- <cfset arguments.programID = qGettemplatesettings.Ez_Contract_ID />
            </cfif>
          </cfif>
         </cfif> --->
			</cfif><!--- END <cfif isdefined("arguments.template_id") and arguments.template_id NEQ 0> --->

			<!--- GeneralSettingsManager =  CreateObject("component", "components.settings.ApplicationSettingsManager").init().get(); --->
			<cfset GeneralSettingsManager = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
			<!---check for groups, if we have any then we have to filter on Is_Group--->
			<!--- <cfset qCheckForGroup = GroupDataManager.getGroupsForProgram(arguments.programID, 2) /> --->

			<cfset appSettings = application.appSettingsGet>


			<cfif arguments.EZOriginalProgramID neq 0 and IsDateExclusion eq 0><!--- copy of ez button program --->
				<!--- on ez program copy,
				- get component which are in both original program and the template
				- get component details which can be edited in the program from the original program (paid to, claim mech)
				- get component details which cannot be edited in the program from the template (rate)
				- get products which are there in both original program and the template
				- get the rate from the template
				--->
 	      <!---
    				Dev Notes: D24626/Anand Rao/07-Sep-10
    				Event error opening program 1030177
            An error was caused when there were multiple records with the same Discount_Type_ID and Component_ID
            combination in the Program_Payment_Cycle table. Hence added a Distinct keyword so that only one record
            with the combination is selected.
	      --->
				<cfquery name="qGetComps" datasource="#application.datasource#">
					SELECT 	DISTINCT
							Program_Rebates_Component.Program_Rebates_Component_ID,<!--- from template --->
							Program_Rebates_Component_EZ_Original_Program.Program_ID,
							Program_Rebates_Component_EZ_Original_Program.Program_Rebates_Component_Name_ID,
							Program_Rebates_Component_EZ_Original_Program.Component_Paid_To,
							---Program_Rebates_Component_EZ_Original_Program.Claim_Mechanics,
							ISNULL(NULLIF(Program_Rebates_Component_EZ_Original_Program.Claim_Mechanics, 0), -1) AS Claim_Mechanics,<!---D3474Programs with fixed price component show claim mechanic of auto credit --->
							ISNULL(Program_Rebates_Component_EZ_Original_Program.GL_Account_ID,0) GL_Account_ID,
	  						Program_Rebates_Component_EZ_Original_Program.Vendor_Master_ID,
							Program_Rebates_Component_EZ_Original_Program.Vendor_Selection,
							isnull(nullif(Program_Rebates_Component_EZ_Original_Program.Payee_Type,''),0) As Payee_Selection,
							<!--- <cfif arguments.RevisionOfExistingContract eq "1"> --->
							Program_Rebates_Component_EZ_Original_Program.Program_Rebates_Component_ID as Parent_Program_Rebates_Component_ID,
							<!--- <cfelse>
							Program_Rebates_Component.Parent_Program_Rebates_Component_ID,
							</cfif>	--->
							ISNULL(Program_Rebates_Component_EZ_Original_Program.Basis_Code_Master_ID, 0) Basis_Code_Master_ID,
							ISNULL(Program_Rebates_Component_EZ_Original_Program.Treatment_Code_Master_ID, 0) Treatment_Code_Master_ID,
							ISNULL(Program_Rebates_Component_EZ_Original_Program.Effective_Margin_Flag, 0) Effective_Margin_Flag
							<cfif appSettings.getPaymentCycleAtDiscountType()>
								,Program_Payment_Cycle.Payment_Cycle_ID AS PaymentCycle
							<cfelse>
								,NULL AS PaymentCycle
							</cfif>
					FROM 	Program_Rebates_Component

					INNER JOIN Program_Rebates_Component as Program_Rebates_Component_EZ_Original_Program
					ON		Program_Rebates_Component_EZ_Original_Program.Deleted = 0
					AND		Program_Rebates_Component_EZ_Original_Program.Program_ID = #arguments.EZOriginalProgramID#
					AND		Program_Rebates_Component_EZ_Original_Program.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID
					<cfif appSettings.getPaymentCycleAtDiscountType()>
						LEFT JOIN Program_Payment_Cycle
						ON Program_Payment_Cycle.Discount_Type_ID = 2
						AND Program_Payment_Cycle.Program_ID = Program_Rebates_Component_EZ_Original_Program.Program_ID
						AND Program_Payment_Cycle.Component_ID = Program_Rebates_Component_EZ_Original_Program.Program_Rebates_Component_ID
						AND Program_Payment_Cycle.Deleted = 0
					</cfif>
					WHERE 	Program_Rebates_Component.Program_ID = #arguments.programID#
					AND		Program_Rebates_Component.Deleted = 0
					ORDER BY Program_Rebates_Component.Program_Rebates_Component_ID
				</cfquery>
			<cfelse>
				<cfquery name="qGetComps" datasource="#application.datasource#">
					SELECT DISTINCT	PRC.Program_Rebates_Component_ID,
							PRC.Program_ID,
							PRC.Program_Rebates_Component_Name_ID,
							PRC.Component_Paid_To,
							---PRC.Claim_Mechanics,
							ISNULL(NULLIF(PRC.Claim_Mechanics, 0), -1) AS Claim_Mechanics,<!---D3474Programs with fixed price component show claim mechanic of auto credit --->
							ISNULL(GL_Account_ID,0) GL_Account_ID,
							PRC.Vendor_Master_ID,
							PRC.Vendor_Selection,
							isnull(nullif(PRC.Payee_Type,''),0) As Payee_Selection,
							ISNULL(Basis_Code_Master_ID, 0) Basis_Code_Master_ID,
							ISNULL(Treatment_Code_Master_ID, 0) Treatment_Code_Master_ID,
							ISNULL(Effective_Margin_Flag, 0) Effective_Margin_Flag,
							<!--- <cfif arguments.RevisionOfExistingContract eq "1"> --->
							PRC.Program_Rebates_Component_ID as Parent_Program_Rebates_Component_ID
							<!--- <cfelse>
							PRC.Parent_Program_Rebates_Component_ID
							</cfif>	 --->
							<cfif appSettings.getPaymentCycleAtDiscountType()>
								,Program_Payment_Cycle.Payment_Cycle_ID AS PaymentCycle
							<cfelse>
								,NULL AS PaymentCycle
							</cfif>
					FROM 	Program_Rebates_Component PRC
					<cfif appSettings.getPaymentCycleAtDiscountType()>
						LEFT JOIN Program_Payment_Cycle
						ON Program_Payment_Cycle.Discount_Type_ID = 2
						AND Program_Payment_Cycle.Program_ID = PRC.Program_ID
						AND Program_Payment_Cycle.Component_ID = PRC.Program_Rebates_Component_ID
						AND Program_Payment_Cycle.Deleted = 0
					</cfif>
					LEFT JOIN Program_Rebates_Component_Profile PRCP ON
							PRCP.Program_Rebates_Component_Name_ID = PRC.Program_Rebates_Component_Name_ID AND
							PRCP.Profiles_ID = #request.AccessStructure.Profiles_ID# AND
							PRCP.Deleted = 0
					<cfif IsDateExclusion eq 0>
					WHERE 	PRC.Program_ID = #arguments.programID# 
					<cfelse>
					WHERE 	PRC.Program_ID IN (#arguments.programID#)
					</cfif>
					AND		PRC.Deleted = 0 AND
							(PRCP.Program_Rebates_Component_Profile_ID IS NULL OR PRCP.Allow_User_To_View = 1)
					ORDER BY PRC.Program_Rebates_Component_ID
				</cfquery>
			</cfif>

			<cfquery name="qGetProds" datasource="#application.datasource#">
				IF OBJECT_ID('tempdb..##tmp_rebate_rates') IS NOT NULL
       			DROP TABLE ##tmp_rebate_rates

        <cfif arguments.EZOriginalProgramID neq 0><!--- copy of ez button program --->
				<!--- on ez program copy,
				- get products which are there in both original program and the template
				--->

				CREATE TABLE ##Tmp_Program_Product_EZ_Original_Program
				(
					Contract_Products_ID Int,
					Product_ID uniqueidentifier,
					product_Type_ID Int,
					Program_Rebates_Component_Name_ID int,
					Component_Paid_To int,
					Rate decimal(20, 4),
					EZ_Contract_Max_Rate decimal(20, 4)
				)
				INSERT INTO ##Tmp_Program_Product_EZ_Original_Program
				SELECT	DISTINCT Contract_Products.Contract_Products_ID, Contract_Products.BSA_Foodservice_Items_Master_ID, product_Type_ID,
					Program_Rebates_Component.Program_Rebates_Component_Name_ID,
					Program_Rebates_Component.Component_Paid_To,
					Program_Rebates_Component_Data.rate,
					Program_Rebates_Component_Data.EZ_Contract_Max_Rate
				FROM	Contract_Products
				INNER JOIN Program_Rebates_Product_Data PRPD
				ON	PRPD.Contract_Products_ID = Contract_Products.Contract_Products_ID
				AND	PRPD.Deleted = 0
				INNER JOIN Program_Rebates_Component_Data
				ON	Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID = PRPD.Program_Rebates_Product_Data_ID
				AND	Program_Rebates_Component_Data.Deleted = 0
				INNER JOIN Program_Rebates_Component
				ON	Program_Rebates_Component.Program_Rebates_Component_ID = Program_Rebates_Component_Data.Program_Rebates_Component_ID
				AND	Program_Rebates_Component.Deleted = 0
				WHERE	Contract_Products.Contract_Main_ID = '#arguments.EZOriginalProgramID#'
				AND 	Contract_Products.product_Type_ID = 2
				AND 	Contract_Products.Deleted = 0
				AND		Contract_Products.Captured_From_Group = 0
		</cfif>
				SELECT 	DISTINCT
						<cfif IsDateExclusion eq 0>
							<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getUseProductHierarchy()>
								Product_Hierarchy.Product_Hierarchy,
							</cfif>
						<cfelse>
							<!--- Tim Ford - Label 44732 - application throwing error when I try to open prog. BSA_Foodservice_Items_Master_ID is in the query twice.
							Contract_Products.BSA_Foodservice_Items_Master_ID,
							--->
							Contract_Products.Contract_Main_ID,
						</cfif>
						PRPD.Program_Rebates_Product_Data_ID,
						PRPD.Program_ID,
						PRPD.Volume,
						ISNULL(PRPD.Competitor_Name_ID,0) as Competitor_Name_ID,
						ISNULL(PRPD.Competitor_Price,0) as Competitor_Price,
						PRPD.Competitor_Time_Frame,
						Contract_Products.Contract_Products_ID,
						Contract_Products.Product_Type_ID,
						Contract_Products.Product_Group_Level_ID,
						Contract_Products.Product_Group_ID,
						Contract_Products.EZButton_On_Default,
						Contract_Products.EZ_Contract_ID,
						ISNULL(Contract_Products.Pricing_Level_ID, 1) Pricing_Level_ID,
						Contract_Products.Is_Group,
						All_Product_Group_Types.Group_Number,
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
						BSA_Foodservice_Items_Master.Item,
						BSA_Foodservice_Items_Master.UPC,
						BSA_Foodservice_Items_Master.Description,
						BSA_Foodservice_Items_Master.Inventory_UM,
						BSA_Foodservice_Items_Master.net_weight,
						BSA_Foodservice_Items_Master.Type_Code_Desc_ID,
						ISNULL(BSA_Foodservice_Items_Master.EA_Conversion, 1) as EA_Conversion,
						BSA_Foodservice_Items_Master.Pack_Size,
						BSA_Foodservice_Items_Master.Pack_Size_UOM,
						Contract_Main.Contract_Start_Date,
						Contract_Main.Contract_End_Date,
						Contract_Main.IsExclusionRevision,
						PRCD.Program_Rebates_Component_ID,
						---xxxxxxxx
						Cast(isnull(nullif(PRCD.Rate,''),0) as decimal(10,4)) As reb_Rate,
						Cast(isnull(nullif(PRCD.Ez_Contract_Max_Rate,''),0) as decimal(10,4)) As Ez_Contract_Max_Rate_DB,
						isnull(PRCD.Unit_Of_Measure_ID,1) AS Unit_Of_Measure_ID,
						isnull(PRCD.Scan_Rate,0) AS Scan_Rate,
						isnull(PRCD.Scan_Volume,0) AS Scan_Volume,
						isnull(PRCD.Scan_Uom,0) AS Scan_Uom,
						PRCD.Program_Rebates_Component_Rule_ID,
						ISNULL(PRCD.Basis_Code_Quantity, 0) Basis_Code_Quantity,
						IsNull(PRCD.Basis_Code_Quantity_UOM, 0) Basis_Code_Quantity_UOM,
						PRCD.Basis_Code_Free_Goods,
						ISNULL(PRCD.Effective_Margin_Percent, 100) Effective_Margin_Percent,
						isnull(PRCD.Program_Rebates_Component_Data_ID,0) Program_Rebates_Component_Data_ID,
						Program_Rebates_Component.Program_Rebates_Component_Name_ID,
						Program_Rebates_Component.Component_Paid_To,
						Contract_Products.Base_Sales_CS <!--- D30357:Today's Price Wrong on Revision History --->
            	INTO	##tmp_rebate_rates
				FROM 	Program_Rebates_Product_Data PRPD
						INNER JOIN Contract_Products
						ON Contract_products.contract_main_id = #arguments.programID#
						AND	Contract_Products.Contract_Products_ID = PRPD.Contract_Products_ID
						AND Contract_Products.Deleted = 0
						AND
						(
							<!------ Group ----->
							(

							Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND

							Contract_Products.Is_Group = 1)
							OR
							<!------ Product ----->
							(ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
						)
						<cfif arguments.contractProdId gt 0>
						AND 	Contract_Products.Contract_Products_Id = #arguments.contractProdId#
						</cfif>
						LEFT JOIN 	Program_Rebates_Component_Data PRCD
						ON			PRCD.Program_Rebates_Product_Data_ID = PRPD.Program_Rebates_Product_Data_ID
						AND 		PRCD.Deleted = 0
            			LEFT JOIN 	Program_Rebates_Component
						ON	Program_Rebates_Component.Program_Rebates_Component_ID = PRCD.Program_Rebates_Component_ID
						AND	Program_Rebates_Component.Deleted = 0
						LEFT JOIN Program_Rebates_Component_Profile PRCP ON
							PRCP.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID AND
							PRCP.Profiles_ID = #request.AccessStructure.Profiles_ID# AND
							PRCP.Deleted = 0

						INNER JOIN BSA_Foodservice_Items_Master
						ON	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
						<cfif arguments.itemMasterId neq "0">
						AND 	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = '#arguments.itemMasterId#'
						</cfif>
						<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getUseProductHierarchy()>
						LEFT JOIN Product_Hierarchy ON
						((Contract_Products.BSA_Foodservice_Items_Master_ID = Product_Hierarchy.Product_Hierarchy_id AND Contract_Products.Is_Group = 1)
						OR (BSA_Foodservice_Items_Master.Product_Hierarchy_id =Product_Hierarchy.Product_Hierarchy_id  AND Contract_Products.Is_Group = 0)
						)
						</cfif>
						INNER JOIN Contract_Main
						ON Contract_Main.Contract_Main_ID =	#arguments.programID#
						<cfif arguments.checktemplatesettings EQ 1 and arguments.groupfieldname IS NOT "">

							<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
							<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo(application.oApplicationAppSettingsManager.getApplicationAppSettings().getTemplateRestrictGroupLevel()) />

							INNER JOIN Template_Allow_Approval_Group ON
							Template_Allow_Approval_Group.Group_ID =
							CASE
								-- Is a product
								WHEN Contract_Products.Is_Group = 0
									THEN bsa_foodservice_items_master.#arguments.groupfieldname#

								-- Is a group, but same group type as the group type in the template, so we can filter out
								WHEN Contract_Products.Is_Group = 1 and Contract_Products.Product_Group_Level_ID = #approvalGroupType.GROUPLEVELID#
									THEN Contract_Products.bsa_foodservice_items_master_id
							ELSE
								Template_Allow_Approval_Group.Group_ID
							END

							AND Template_Allow_Approval_Group.Program_Type_ID = #arguments.template_id#
						</cfif>
						<!--- below condition to be used only when arguments.ClassCodeUserID neq ""
						this function loadFromDB gets called from inside program (eg: rebate, view program) and also from copy/revise
						below section to be executed only when called from copy/revise, assuming only copy/revise will pass arguments.ClassCodeUserID
						--->
						<cfif arguments.RevisionOfExistingContract eq 0>
							<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getClassCodesOn()>
								<cfif arguments.ClassCodeUserID neq "">
								<!--- Dev Note: 12632; Milan. If the user's access to the set of class code changes, then make sure
								that the products belonging to only the new set of class codes get copied over. This rule does
								not apply to revisions. --->
									INNER JOIN User_Class_Code
									ON User_Class_Code.Class_Code_Id =
									CASE
									WHEN Contract_Products.Product_Group_Level_ID IN (0,9) THEN
									BSA_Foodservice_items_master.Class_Code_Id
									ELSE
									User_Class_Code.Class_Code_Id
									END
									AND User_Class_Code.Deleted = 0
									AND User_Class_Code.User_Id = '#arguments.ClassCodeUserID#'
									INNER JOIN Class_Code
									ON Class_Code.Class_Code_UUID =
									CASE Contract_Products.Product_Group_Level_ID
									WHEN 10 THEN
									Contract_Products.BSA_Foodservice_Items_Master_ID
									ELSE
									Class_Code.Class_Code_UUID
									END
									AND User_Class_Code.Class_Code_Id = Class_Code.Class_Code_Id
								</cfif>
							</cfif>
						</cfif>
						<!--- Dev Note: Milan;18088 - "All_Product_Group_Types" table stores all the groups and has a
							  "deleted" field, which we look at to make sure we include valid groups only.
					    --->
						LEFT JOIN All_Product_Group_Types ON
						All_Product_Group_Types.Product_Group_Level_ID = Contract_Products.Product_Group_Level_ID
						AND CAST(All_Product_Group_Types.Group_GUID AS VARCHAR(50)) = Contract_Products.Product_Group_ID

				<cfif IsDateExclusion eq 0>
				WHERE 	PRPD.Program_ID = #arguments.programID#

				<cfelse>
				WHERE 	PRPD.Program_ID IN (#arguments.programID#)
				</cfif>
				AND		PRPD.Deleted = 0
				<cfif arguments.CheckForActiveProductsOnly EQ 1> <!--- Dev Note: KAL; 8362 --->
				AND ((Contract_Products.Is_Group = 1 AND All_Product_Group_Types.Deleted = 0) OR (BSA_Foodservice_Items_Master.active_code = 'A' AND BSA_Foodservice_Items_Master.Deleted = 0))
				</cfif>
				--AND 	Contract_Main.deleted = 0
				<cfif arguments.checktemplatesettings EQ 1>
				<cfif qGettemplatesettings.Discount_Rebates_Item_Level EQ 1 and  qGettemplatesettings.Discount_Rebates_Group_Level EQ 0>
				AND (Contract_Products.Is_Group = 0)
				</cfif>
				<cfif qGettemplatesettings.Discount_Rebates_Group_Level EQ 1 and qGettemplatesettings.Discount_Rebates_Item_Level EQ 0>
				AND (Contract_Products.Is_Group = 1)
				</cfif>
				</cfif>
				<cfif arguments.EZOriginalProgramID neq 0><!--- copy of ez button program --->
				AND		Contract_Products.BSA_Foodservice_Items_Master_ID IN
				(SELECT	Product_ID FROM ##Tmp_Program_Product_EZ_Original_Program)
					<cfif qGetComps.recordCount eq 0>
					AND 1=2
          <!--- cfelse --->
         <!---  -- Added for bringing only the products that are in the above component to be copied.
          -- 21553: HZ - min/max rates for EZ button/Anand Rao/ 15-Mar-10
          -- AND Program_Rebates_Component.Program_Rebates_Component_ID IN (#ValueList(qGetComps.Program_Rebates_Component_ID)#)  --->
					 </cfif>
				</cfif>
				AND (PRCP.Program_Rebates_Component_Profile_ID IS NULL OR PRCP.Allow_User_To_View = 1)
        <cfif (arguments.EZOriginalProgramID neq 0 AND bDiscountRebateMaxRateOn EQ 1)>
          -- Revision Scenario 4 OR Copy Scenario 2
          UPDATE	##tmp_rebate_rates
          SET	reb_Rate = ##Tmp_Program_Product_EZ_Original_Program.Rate
          FROM	##tmp_rebate_rates
          INNER JOIN ##Tmp_Program_Product_EZ_Original_Program
          ON	##Tmp_Program_Product_EZ_Original_Program.Product_ID = ##tmp_rebate_rates.BSA_Foodservice_Items_Master_ID
          AND	##Tmp_Program_Product_EZ_Original_Program.Program_Rebates_Component_Name_ID = ##tmp_rebate_rates.Program_Rebates_Component_Name_ID
          AND	##Tmp_Program_Product_EZ_Original_Program.Component_Paid_To = ##tmp_rebate_rates.Component_Paid_To
          AND	##Tmp_Program_Product_EZ_Original_Program.Rate < ##tmp_rebate_rates.reb_Rate
        </cfif>

        SELECT	*,
        <cfif bDiscountRebateMaxRateOn eq 1><!--- arguments.EZOriginalProgramID was used earlier --->
        CASE WHEN Ez_Contract_Max_Rate_DB = 0 THEN
          reb_Rate
        ELSE
          Ez_Contract_Max_Rate_DB
        END as Ez_Contract_Max_Rate
        <cfelse>
          Ez_Contract_Max_Rate_DB AS Ez_Contract_Max_Rate
        </cfif>
        FROM	##tmp_rebate_rates
		<!---	Dev Note: KAL; 8/17/2010; D24330 : Event error when clicking revise on programs.
				Moving the order by here for event errors from Solo --->
		<cfif IsDateExclusion eq 0>
			<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getUseProductHierarchy()>
				ORDER BY Pricing_Level_ID, Product_Hierarchy, Product_Group_Level_ID asc, Item, Description, BSA_Foodservice_Items_Master_ID, Program_Rebates_Component_ID
			<cfelse>
				ORDER BY Pricing_Level_ID, Item, Description, BSA_Foodservice_Items_Master_ID, Program_Rebates_Component_ID
			</cfif>
		<cfelse>
			ORDER BY Item, BSA_Foodservice_Items_Master_ID, Contract_Main_ID, Pricing_Level_ID, Program_Rebates_Component_ID
		</cfif>

        DROP TABLE ##tmp_rebate_rates
				<cfif arguments.EZOriginalProgramID neq 0><!--- copy of ez button program --->
				DROP TABLE ##Tmp_Program_Product_EZ_Original_Program
				</cfif>
		</cfquery>

				<!--- START: 25709: EZ Button/Anand Rao/25-Mar-2011 --->
<cfif (isdefined("arguments.template_id") and arguments.template_id NEQ 0 AND qGetProds.RecordCount EQ 0 AND	arguments.EZButton_On EQ 1 AND qGetTemplateSettings.EzButton_Default_Show_Item_Rates EQ 1)>
<!--- If the above query returns RecordCount of 0 then that means program is just being created or is in edit mode but no products added. So in both these cases we will display the items and rates in the template   --->

		<cfquery name="qGetProds" datasource="#application.datasource#">
				IF OBJECT_ID('tempdb..##tmp_rebate_rates') IS NOT NULL
        DROP TABLE ##tmp_rebate_rates

        <cfif arguments.EZOriginalProgramID neq 0><!--- copy of ez button program --->
				<!--- on ez program copy,
				- get products which are there in both original program and the template
				--->

				CREATE TABLE ##Tmp_Program_Product_EZ_Original_Program
				(
					Contract_Products_ID Int,
					Product_ID uniqueidentifier,
					product_Type_ID Int,
					Program_Rebates_Component_Name_ID int,
					Component_Paid_To int,
					Rate decimal(20, 4),
					EZ_Contract_Max_Rate decimal(20, 4)
				)
				INSERT INTO ##Tmp_Program_Product_EZ_Original_Program
				SELECT	DISTINCT Contract_Products.Contract_Products_ID, Contract_Products.BSA_Foodservice_Items_Master_ID, product_Type_ID,
					Program_Rebates_Component.Program_Rebates_Component_Name_ID,
					Program_Rebates_Component.Component_Paid_To,
					Program_Rebates_Component_Data.rate,
					Program_Rebates_Component_Data.EZ_Contract_Max_Rate
				FROM	Contract_Products
				INNER JOIN Program_Rebates_Product_Data PRPD
				ON	PRPD.Contract_Products_ID = Contract_Products.Contract_Products_ID
				AND	PRPD.Deleted = 0
				INNER JOIN Program_Rebates_Component_Data
				ON	Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID = PRPD.Program_Rebates_Product_Data_ID
				AND	Program_Rebates_Component_Data.Deleted = 0
				INNER JOIN Program_Rebates_Component
				ON	Program_Rebates_Component.Program_Rebates_Component_ID = Program_Rebates_Component_Data.Program_Rebates_Component_ID
				AND	Program_Rebates_Component.Deleted = 0
				WHERE	Contract_Products.Contract_Main_ID = '#arguments.EZOriginalProgramID#'
				AND 	Contract_Products.product_Type_ID = 2
				AND 	Contract_Products.Deleted = 0
				AND		Contract_Products.Captured_From_Group = 0
				</cfif>
				SELECT 	DISTINCT
						<cfif IsDateExclusion eq 0>
							<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getUseProductHierarchy()>
								Product_Hierarchy.Product_Hierarchy,
							</cfif>
						<cfelse>
							Contract_Products.BSA_Foodservice_Items_Master_ID,
							Contract_Products.Contract_Main_ID,
						</cfif>
						PRPD.Program_Rebates_Product_Data_ID,
						PRPD.Program_ID,
						PRPD.Volume,
						ISNULL(PRPD.Competitor_Name_ID,0) as Competitor_Name_ID,
						ISNULL(PRPD.Competitor_Price,0) as Competitor_Price,
						PRPD.Competitor_Time_Frame,
						Contract_Products.Contract_Products_ID,
						Contract_Products.Product_Type_ID,
						Contract_Products.Product_Group_Level_ID,
						Contract_Products.Product_Group_ID,
						Contract_Products.EZButton_On_Default,
						Contract_Products.EZ_Contract_ID,
						ISNULL(Contract_Products.Pricing_Level_ID, 1) Pricing_Level_ID,
						Contract_Products.Is_Group,
						All_Product_Group_Types.Group_Number,
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
						BSA_Foodservice_Items_Master.Item,
						BSA_Foodservice_Items_Master.UPC,
						BSA_Foodservice_Items_Master.Description,
						BSA_Foodservice_Items_Master.Inventory_UM,
						BSA_Foodservice_Items_Master.net_weight,
						BSA_Foodservice_Items_Master.Type_Code_Desc_ID,
						ISNULL(BSA_Foodservice_Items_Master.EA_Conversion, 1) as EA_Conversion,
						BSA_Foodservice_Items_Master.Pack_Size,
						BSA_Foodservice_Items_Master.Pack_Size_UOM,
						Contract_Main.Contract_Start_Date,
						Contract_Main.Contract_End_Date,
						Contract_Main.IsExclusionRevision,
						PRCD.Program_Rebates_Component_ID,
						---xxxxxxxx
						Cast(isnull(nullif(PRCD.Rate,''),0) as decimal(10,4)) As reb_Rate,
						Cast(isnull(nullif(PRCD.Ez_Contract_Max_Rate,''),0) as decimal(10,4)) As Ez_Contract_Max_Rate_DB,
						isnull(PRCD.Unit_Of_Measure_ID,1) AS Unit_Of_Measure_ID,
						isnull(PRCD.Scan_Rate,0) AS Scan_Rate,
						isnull(PRCD.Scan_Volume,0) AS Scan_Volume,
						isnull(PRCD.Scan_Uom,0) AS Scan_Uom,
						PRCD.Program_Rebates_Component_Rule_ID,
						ISNULL(PRCD.Basis_Code_Quantity, 0) Basis_Code_Quantity,
						IsNull(PRCD.Basis_Code_Quantity_UOM, 0) Basis_Code_Quantity_UOM,
						PRCD.Basis_Code_Free_Goods,
						ISNULL(PRCD.Effective_Margin_Percent, 100) Effective_Margin_Percent,
						isnull(PRCD.Program_Rebates_Component_Data_ID,0) Program_Rebates_Component_Data_ID,
						Program_Rebates_Component.Program_Rebates_Component_Name_ID, 
						Program_Rebates_Component.Component_Paid_To,
						Contract_Products.Base_Sales_CS <!--- D30357:Today's Price Wrong on Revision History --->
						---xxxxxxxxx
            into	##tmp_rebate_rates
				FROM 	Program_Rebates_Product_Data PRPD
						INNER JOIN Contract_Products ON
						Contract_products.contract_main_id = #arguments.programID# AND
						Contract_Products.Contract_Products_ID = PRPD.Contract_Products_ID
						AND Contract_Products.Deleted = 0

						AND
						(
							<!------ Group ----->
							(Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
							OR
							<!------ Product ----->
							(ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
						)
						<cfif arguments.contractProdId gt 0>
						AND 	Contract_Products.Contract_Products_Id = #arguments.contractProdId#
						</cfif>
						LEFT JOIN Program_Rebates_Component_Data PRCD ON
							PRCD.Program_Rebates_Product_Data_ID = PRPD.Program_Rebates_Product_Data_ID
							AND PRCD.Deleted = 0
            LEFT JOIN Program_Rebates_Component
						ON	Program_Rebates_Component.Program_Rebates_Component_ID = PRCD.Program_Rebates_Component_ID
						AND	Program_Rebates_Component.Deleted = 0

						INNER JOIN BSA_Foodservice_Items_Master ON
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
						<cfif arguments.itemMasterId neq "0">
						AND 	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = '#arguments.itemMasterId#'
						</cfif>
						<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getUseProductHierarchy()>
						left join Product_Hierarchy on
						((Contract_Products.BSA_Foodservice_Items_Master_ID = Product_Hierarchy.Product_Hierarchy_id AND Contract_Products.Is_Group = 1)
							OR

							(BSA_Foodservice_Items_Master.Product_Hierarchy_id =Product_Hierarchy.Product_Hierarchy_id  AND Contract_Products.Is_Group = 0)
						)
						</cfif>
						INNER JOIN Contract_Main
						ON Contract_Main.Contract_Main_ID =	#arguments.programID#
						<cfif arguments.checktemplatesettings EQ 1 and arguments.groupfieldname IS NOT "">

							<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
							<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo(application.oApplicationAppSettingsManager.getApplicationAppSettings().getTemplateRestrictGroupLevel()) />

							INNER JOIN Template_Allow_Approval_Group ON
							Template_Allow_Approval_Group.Group_ID =
							CASE
								-- Is a product
								WHEN Contract_Products.Is_Group = 0
									THEN bsa_foodservice_items_master.#arguments.groupfieldname#

								-- Is a group, but same group type as the group type in the template, so we can filter out
								WHEN Contract_Products.Is_Group = 1 and Contract_Products.Product_Group_Level_ID = #approvalGroupType.GROUPLEVELID#
									THEN Contract_Products.bsa_foodservice_items_master_id
							ELSE
								Template_Allow_Approval_Group.Group_ID
							END

							AND Template_Allow_Approval_Group.Program_Type_ID = #arguments.template_id#
						</cfif>
						<!--- below condition to be used only when arguments.ClassCodeUserID neq ""
						this function loadFromDB gets called from inside program (eg: rebate, view program) and also from copy/revise
						below section to be executed only when called from copy/revise, assuming only copy/revise will pass arguments.ClassCodeUserID
						--->
						<cfif arguments.RevisionOfExistingContract eq 0>
							<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getClassCodesOn()>
								<cfif arguments.ClassCodeUserID neq "">
								<!--- Dev Note: 12632; Milan. If the user's access to the set of class code changes, then make sure
								that the products belonging to only the new set of class codes get copied over. This rule does
								not apply to revisions. --->
									INNER JOIN User_Class_Code
									ON User_Class_Code.Class_Code_Id =
									CASE
									WHEN Contract_Products.Product_Group_Level_ID IN (0,9) THEN
									BSA_Foodservice_items_master.Class_Code_Id
									ELSE
									User_Class_Code.Class_Code_Id
									END
									AND User_Class_Code.Deleted = 0
									AND User_Class_Code.User_Id = '#arguments.ClassCodeUserID#'
									INNER JOIN Class_Code
									ON Class_Code.Class_Code_UUID =
									CASE Contract_Products.Product_Group_Level_ID
									WHEN 10 THEN
									Contract_Products.BSA_Foodservice_Items_Master_ID
									ELSE
									Class_Code.Class_Code_UUID
									END
									AND User_Class_Code.Class_Code_Id = Class_Code.Class_Code_Id
								</cfif>
							</cfif>
						</cfif>
						<!--- Dev Note: Milan;18088 - "All_Product_Group_Types" table stores all the groups and has a
							  "deleted" field, which we look at to make sure we include valid groups only.
					    --->
						LEFT JOIN All_Product_Group_Types ON
						All_Product_Group_Types.Product_Group_Level_ID = Contract_Products.Product_Group_Level_ID
						AND CAST(All_Product_Group_Types.Group_GUID AS VARCHAR(50)) = Contract_Products.Product_Group_ID

				<cfif IsDateExclusion eq 0>
				WHERE 	PRPD.Program_ID = #arguments.programID#

				<cfelse>
				WHERE 	PRPD.Program_ID IN (#arguments.programID#)
				</cfif>
				AND		PRPD.Deleted = 0
				<cfif arguments.CheckForActiveProductsOnly EQ 1> <!--- Dev Note: KAL; 8362 --->
				AND ((Contract_Products.Is_Group = 1 AND All_Product_Group_Types.Deleted = 0) OR (BSA_Foodservice_Items_Master.active_code = 'A' AND BSA_Foodservice_Items_Master.Deleted = 0))
				</cfif>
				--AND 	Contract_Main.deleted = 0
				<cfif arguments.checktemplatesettings EQ 1>
				<cfif qGettemplatesettings.Discount_Rebates_Item_Level EQ 1 and  qGettemplatesettings.Discount_Rebates_Group_Level EQ 0>
				AND (Contract_Products.Is_Group = 0)
				</cfif>
				<cfif qGettemplatesettings.Discount_Rebates_Group_Level EQ 1 and qGettemplatesettings.Discount_Rebates_Item_Level EQ 0>
				AND (Contract_Products.Is_Group = 1)
				</cfif>
				</cfif>
				<cfif arguments.EZOriginalProgramID neq 0><!--- copy of ez button program --->
				AND		Contract_Products.BSA_Foodservice_Items_Master_ID IN
				(SELECT	Product_ID FROM ##Tmp_Program_Product_EZ_Original_Program)
					<cfif qGetComps.recordCount eq 0>
					AND 1=2
          <!--- cfelse --->
         <!---  -- Added for bringing only the products that are in the above component to be copied.
          -- 21553: HZ - min/max rates for EZ button/Anand Rao/ 15-Mar-10
          -- AND Program_Rebates_Component.Program_Rebates_Component_ID IN (#ValueList(qGetComps.Program_Rebates_Component_ID)#)  --->
					 </cfif>
				</cfif>

        <cfif (arguments.EZOriginalProgramID neq 0 AND bDiscountRebateMaxRateOn EQ 1)>
          -- Revision Scenario 4 OR Copy Scenario 2
          UPDATE	##tmp_rebate_rates
          SET	reb_Rate = ##Tmp_Program_Product_EZ_Original_Program.Rate
          FROM	##tmp_rebate_rates
          INNER JOIN ##Tmp_Program_Product_EZ_Original_Program
          ON	##Tmp_Program_Product_EZ_Original_Program.Product_ID = ##tmp_rebate_rates.BSA_Foodservice_Items_Master_ID
          AND	##Tmp_Program_Product_EZ_Original_Program.Program_Rebates_Component_Name_ID = ##tmp_rebate_rates.Program_Rebates_Component_Name_ID
          AND	##Tmp_Program_Product_EZ_Original_Program.Component_Paid_To = ##tmp_rebate_rates.Component_Paid_To
          AND	##Tmp_Program_Product_EZ_Original_Program.Rate < ##tmp_rebate_rates.reb_Rate
        </cfif>

        SELECT	*,
        <cfif bDiscountRebateMaxRateOn eq 1><!--- arguments.EZOriginalProgramID was used earlier --->
        CASE WHEN Ez_Contract_Max_Rate_DB = 0 THEN
          reb_Rate
        ELSE
          Ez_Contract_Max_Rate_DB
        END as Ez_Contract_Max_Rate
        <cfelse>
          Ez_Contract_Max_Rate_DB AS Ez_Contract_Max_Rate
        </cfif>
        FROM	##tmp_rebate_rates
		<!---	Dev Note: KAL; 8/17/2010; D24330 : Event error when clicking revise on programs.
				Moving the order by here for event errors from Solo --->
		<cfif IsDateExclusion eq 0>
			<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getUseProductHierarchy()>
				ORDER BY Pricing_Level_ID, Product_Hierarchy, Product_Group_Level_ID asc, Item, Description, BSA_Foodservice_Items_Master_ID, Program_Rebates_Component_ID
			<cfelse>
				ORDER BY Pricing_Level_ID, Item, Description, BSA_Foodservice_Items_Master_ID, Program_Rebates_Component_ID
			</cfif>
		<cfelse>
			ORDER BY Item, BSA_Foodservice_Items_Master_ID, Contract_Main_ID, Pricing_Level_ID, Program_Rebates_Component_ID
		</cfif>

        DROP TABLE ##tmp_rebate_rates
				<cfif arguments.EZOriginalProgramID neq 0><!--- copy of ez button program --->
				DROP TABLE ##Tmp_Program_Product_EZ_Original_Program
				</cfif>
			</cfquery>

</cfif>


				<!--- END: 25709: EZ Button/Anand Rao/25-Mar-2011 --->



			<cfloop query="qGetComps">
				<!--- D38536  :: Alternate recapture rates per component START--->
					<cfset useLakebaseForARSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("alternate_recapture_rate_setting")>
<cfif useLakebaseForARSettings>
	<cftry>
		<cfset ARSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("alternate_recapture_rate_setting", {
				"program_rebates_component_name_id" = "eq.#Program_Rebates_Component_Name_ID#",
				"status" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForARSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForARSettings>
<cfquery name="ARSettings" datasource="#application.datasource#">
						SELECT *
						FROM Alternate_Recapture_Rate_Setting
						WHERE Program_Rebates_Component_Name_ID = #Program_Rebates_Component_Name_ID#
						AND Status = 0
					</cfquery>
</cfif>
				<!--- D38536  :: Alternate recapture rates per component END--->
				<cfscript>
					//qGetCompName = comp.getComp(qGetComps.Program_Rebates_Component_Name_ID);
					ArrayAppend(this.stRebate.aComp,
						comp.set(
							compID = qGetComps.Program_Rebates_Component_ID,
							compNameId = qGetComps.Program_Rebates_Component_Name_ID,
							programID = qGetComps.Program_ID,
							compUUID = qGetComps.Program_Rebates_Component_ID, //createUUID() -> arguments.compUUID,
							componentPaidTo = qGetComps.Component_Paid_To,
							GL_Account_ID = qGetComps.GL_Account_ID,
							Vendor_Master_ID = qGetComps.Vendor_Master_ID,
							PaymentCycle = qGetComps.PaymentCycle,
							Claim_Mechanics = qGetComps.Claim_Mechanics,
							BasisCode = qGetComps.Basis_Code_Master_ID,
							TreatmentCode = qGetComps.Treatment_Code_Master_ID,
							VendorSelection = qGetComps.Vendor_Selection,
							ParentProgramRebatesComponentID = qGetComps.Parent_Program_Rebates_Component_ID,
							Payee_Selection = qGetComps.Payee_Selection
							,Alternate_Recapture_Rate = ARSettings.recordcount // D38536  :: Alternate recapture rates per component
							));
				</cfscript>

			</cfloop>

			<!------ Get pricing level descriptions ----->
			<cfset qGetPricingLevel = GroupDataManager.getPricingLevel() />
			<cfset arPricingLevel = ListToArray(ValueList(qGetPricingLevel.Pricing_Level_Desc, ","), ",") />
			<cfset arPricingLevelLen = ArrayLen(arPricingLevel) />

			<!------
			Inorder to make sure that products in level 2 and level 3 are a sub set of Level 1
			- 	Product search is filtered against Level 1 using the input fields AllowProductGroupList and AllowProductGroupLevelId
			- 	But still user can select group, select product, then use scissors to change/delete the original group selection,
				in that case check this list while submitting the form
			----->
			<cfset qProductGroupValuesForItem = QueryNew("Product_ID,Group_ID") />
			<cfif qGetProds.recordCount>
				<cfif qGetProds.Is_Group>
					<cfset productGroupAttributeManager 	= CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />
					<cfset productGroupType 				= productGroupAttributeManager.getGroupTypeInfo(groupLevelId=qGetProds.Product_Group_Level_ID) />
					<cfset qProductGroupValuesForItem 		= productGroupAttributeManager.getProductGroupValuesForItem(
							productGroupType=productGroupType,
							productIDList	=ValueList(qGetProds.BSA_Foodservice_Items_Master_ID)) />
				</cfif>
			</cfif>


			<cfparam name="this.isGroup" default="0" />
			<cfparam name="this.productGroupLevelTypeId" default="0" />
			<cfset lastItemMasterId = "" />
			<cfset prodCounter  = 0 />
			<cfset compCounter  = 1 />

		<cfloop query="qGetProds">

				<!---set the item master id--->
				<cfset thisItemMasterId = qGetProds.BSA_Foodservice_Items_Master_ID />
				<cfif thisItemMasterId NEQ lastItemMasterId >
					<cfset thisContract_Start_Date = qGetProds.Contract_Start_Date />
					<cfset thisContract_End_Date = qGetProds.Contract_End_Date />
					<cfset thisIsExclusionRevision = qGetProds.IsExclusionRevision />

					<cfset pricingLevelDesc = "" />
					<cfif qGetProds.Pricing_Level_ID GT 0 AND qGetProds.Pricing_Level_ID LTE arPricingLevelLen>
						<cfset pricingLevelDesc = arPricingLevel[qGetProds.Pricing_Level_ID] />
					</cfif>
					<cfset ItemUOM = qGetProds.Inventory_UM  /> <!--- Dev Note: KAL; 9588 --->
					<!---this is by group--->



					<cfif Is_Group EQ 1>
					<!--- Dev Note: drachala; D28957: Template EZ Button errors   START
                    Added/Changed: REMOVED ",FirstParentID = GetTemplateInfo.First_Parent_ID" --->
						<cfset qGetProduct = this.GroupDataManager.getByProductGroupData(prodGroupLevelId=qGetProds.Product_Group_Level_ID, prodGroupId=qGetProds.Product_Group_ID, programId=arguments.programID, byPassUserClassCodeRestriction=1, showAllProductHierarchy=1, IncludeDeleted=1) />
					<!--- End Dev Note: drachala; D28957: Template EZ Button errors  --->
						<!---if product group level type is 2 then we know it's hierarchy so get the hierarchy id--->

						<cfif qGetProduct.Product_Group_Level_Type eq 2>
							<cfset thisItem = 	qGetProduct.Product_Hierarchy />
							<cfif qGetProduct.Unit_Of_Measure_ID EQ 1>
								<cfset ItemUOM	=	"CS" />
							<cfelseif qGetProduct.Unit_Of_Measure_ID EQ 2>
								<cfset ItemUOM	=	"LB" />
							</cfif>

						<cfelse>
							<cfset thisItem = 	"Group" /><!--- D38536  :: Alternate recapture rates per component--->
						</cfif>
						<cfset thisUPC 	=  	"N/A" />
						<!---D35295:Update market pricing to use new group rates grid --->
						<!---<cfset thisDesc	=	qGetProduct.Group_Level_Desc />--->
						<cfset thisDesc	=	qGetProds.Description />
						<!---D35295:Update market pricing to use new group rates grid --->
						<cfset this.isGroup  =	1 />

						<cfset this.productGroupLevelTypeId = qGetProduct.Product_Group_Level_Type />
						<!---changed the item master id to the product group id--->
					<!--- 	<cfset thisItemMasterId = qGetProduct.Product_Group_ID /> --->

					<!---this is for all products--->
					<cfelseif Product_Group_Level_ID eq 1>

						<cfset qGetProduct = ProductGroupManager.getProductGroupDetails(qGetProds.Product_Group_Level_ID, qGetProds.Product_Group_ID) />
						<cfset thisItem = 	qGetProduct.item />
						<cfset thisUPC 	=  	qGetProduct.upc />
						<cfset thisDesc	=	qGetProduct.description />
						<cfset this.isGroup  =	0 />

					<!---this is for item/product/sku--->
					<cfelse>

						<cfset thisItem = 	qGetProds.item />
						<cfset thisUPC 	=  	qGetProds.upc />
						<cfset thisDesc	=	qGetProds.description />
						<cfset this.isGroup  =	0 />

					</cfif>

					<cfset addToGroupLevel(groupLevelId = qGetProds.Product_Group_Level_ID, pricingLevelId = qGetProds.Pricing_Level_ID) />
					<cfif qGetProds.Product_Group_Level_ID eq 0 and
					      qGetProds.Is_Group eq 0 and
					      qGetProds.Product_Group_ID is ""
					      >
					  <cfset Prod_Group_Level_ID = 9 />
					<cfelse>
					 <cfset Prod_Group_Level_ID = qGetProds.Product_Group_Level_ID />
					</cfif>
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D27183 start
						  base sales are displayed on rebate page based on these 2 settings xxxxxxxxxxxxxxxxxxxx              --->
					<cfscript>
						//init
						local.BaseSalesLB = 0;
						local.BaseSalesCS = 0;
						//only popultae this data if we are going to use it
						if(this.appsettings.getshowrebateadditionalfields() && GetTemplateInfo.Single_Component_Per_Discount_Type){
							// D30357:Today's Price Wrong on Revision History START
							if(len(qGetProds.Base_Sales_CS) && qGetProds.Base_Sales_CS != 0 )
								{
											local.BaseSalesLB = Base_Sales_CS/net_weight;
											local.BaseSalesCS = Base_Sales_CS;
								}
								else{

											local.getItemCustPrice = local.bidRequestProdMan.getItemCustPriceForFP(thisItemMasterId,qGetProds.Program_ID,GetContractInfo.price_list_id);

											local.FOB_CS_Price = local.getItemCustPrice.FOB_CS_Price;
											local.FOB_LB_Price = local.getItemCustPrice.FOB_LB_Price;
											local.DEL_CS_Price = local.getItemCustPrice.DEL_CS_Price;
											local.DEl_LB_Price = local.getItemCustPrice.DEL_LB_Price;
											//  USE FOB ---
											//local.BaseSalesLB = local.FOB_LB_Price;
											//local.BaseSalesCS = local.FOB_CS_Price;
											// USE DEL ---
											/*
											-  ????*/

											local.BaseSalesLB = local.DEL_LB_Price;
											local.BaseSalesCS = local.DEL_CS_Price;
								}
								// D30357:Today's Price Wrong on Revision History END

						}
					</cfscript>
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D27183 end --->


					<!---BJF This set is in Product.cfc, the set() method --->
					<cfset ArrayAppend(
										this.stRebate.aProd,
										product.set(
													qGetProds.Contract_Products_ID,
													thisItemMasterId,
													qGetProds.Program_ID,
													qGetProds.Product_Type_ID,
													qGetProds.volume,
													thisItem,
													thisUPC,
													thisDesc,
													ItemUOM,
													EA_Conversion,
													"",
													qGetProds.net_weight,
													Prod_Group_Level_ID,
													qGetProds.Product_Group_ID,
													qGetProds.Pricing_Level_ID,
													pricingLevelDesc,
													this.isGroup,
													this.productGroupLevelTypeId,
													"",
													displayGroupType,
													Type_Code_Desc_ID,
													qProductGroupValuesForItem,
													EZButton_On_Default,
													Pack_Size,
													Pack_Size_UOM,
													EZ_Contract_ID,
													local.BaseSalesLB,
													local.BaseSalesCS,
													qGetProds.Competitor_Name_ID,
													qGetProds.Competitor_Price,
													qGetProds.Competitor_Time_Frame,
													qGetProds.Group_Number
													)
									) />
					<cfset lastItemMasterId = thisItemMasterId />
					<cfset prodCounter  = prodCounter + 1 />
					<cfset compCounter  = 1 />
					<cfscript>
						this.stRebate.aProd[prodCounter].Contract_Start_Date= thisContract_Start_Date;
						this.stRebate.aProd[prodCounter].Contract_End_Date= thisContract_End_Date;
						this.stRebate.aProd[prodCounter].IsExclusionRevision= thisIsExclusionRevision;
					</cfscript>
				<cfelse>
					<cfset compCounter  = compCounter + 1 />
				</cfif>	<!--- if thisItemMasterId NEQ lastItemMasterId from 395 --->
				<!---set the contract id and product data id before going into nested loop--->
				<cfset conProdID = qGetProds.Contract_Products_ID />
				<cfset prodID = qGetProds.Program_Rebates_Product_Data_ID />


				<!--- <cfloop query="qGetComps">

					<cfquery name="qGetCompData" datasource="#application.datasource#">
						SELECT 	Program_Rebates_Component_ID,
								Program_Rebates_Product_Data_ID,
								Cast(Rate as decimal(10,4)) As Rate,
								Unit_Of_Measure_ID,
								Scan_Rate, Scan_Volume, Scan_Uom,
								Program_Rebates_Component_Rule_ID,
								ISNULL(Program_Rebates_Component_Data.Basis_Code_Quantity, 0) Basis_Code_Quantity,
								IsNull(Program_Rebates_Component_Data.Basis_Code_Quantity_UOM, 0) Basis_Code_Quantity_UOM,
								Program_Rebates_Component_Data.Basis_Code_Free_Goods,
								ISNULL(Program_Rebates_Component_Data.Effective_Margin_Percent, 100) Effective_Margin_Percent
						FROM 	Program_Rebates_Component_Data
						WHERE 	Program_Rebates_Component_ID = '#qGetComps.Program_Rebates_Component_ID#'
						AND		Program_Rebates_Product_Data_ID = #prodID#
						AND 	Deleted = 0
						<cfif this.isGroup eq 1>
						AND		Is_Group = 1
						</cfif>
					</cfquery>

					<cfset rebate_rate = qGetCompData.rate />
					<cfset unit_of_measure_id = qGetCompData.unit_of_measure_id />
					<!----- for scan components if the uom selected by the user is "each", we store the rate entered by the user in the scan rate field
					and will store the cs equivalent values in the regular rate fields so that we do not have to change the rest of the application for now.
					once we have logic to handle uom="each" in other parts of the app we can remove the following conversion.

					if rebate type = Variable/Fixed Combo and uom=EA
					----->
					<cfif this.stRebate.aComp[CurrentRow].rebate_type eq 4 and qGetCompData.Scan_Uom eq 5>
						<cfset unit_of_measure_id = qGetCompData.Scan_Uom />
						<cfset rebate_rate = qGetCompData.Scan_Rate />
					</cfif>

					<cfscript>
						aCompVal = rate.set(
										rebate_rate,
										unit_of_measure_id,
										qGetCompData.Program_Rebates_Component_ID,
										conProdID,
										qGetCompData.Program_Rebates_Component_Rule_ID,
										qGetCompData.Basis_Code_Quantity,
										qGetCompData.Basis_Code_Quantity_UOM,
										qGetCompData.Basis_Code_Free_Goods,
										qGetCompData.Effective_Margin_Percent,
										qGetCompData.Scan_Volume
										);
					</cfscript>

					<cfset this.stRebate.aCompVal[qGetProds.CurrentRow][CurrentRow] = aCompVal />

				</cfloop> --->
					<cfset rebate_rate = qGetProds.reb_rate />
					<cfset uom = qGetProds.unit_of_measure_id />
					<!----- for scan components if the uom selected by the user is "each", we store the rate entered by the user in the scan rate field
					and will store the cs equivalent values in the regular rate fields so that we do not have to change the rest of the application for now.
					once we have logic to handle uom="each" in other parts of the app we can remove the following conversion.

					if rebate type = Variable/Fixed Combo and uom=EA
					----->
					<CFIF trim(qGetProds.Program_Rebates_Component_ID) NEQ "" >
						<cfif this.stRebate.aComp[compCounter].rebate_type eq 4 and qGetProds.Scan_Uom eq 5>
							<cfset uom = qGetProds.Scan_Uom />
							<cfset rebate_rate = qGetProds.Scan_Rate />
						</cfif>
						<!--- aCompVal = rate.set(
												rebate_rate,
												unit_of_measure_id,
												qGetProds.Program_Rebates_Component_ID,
												conProdID,
												qGetProds.Program_Rebates_Component_Rule_ID,
												qGetProds.Basis_Code_Quantity,
												qGetProds.Basis_Code_Quantity_UOM,
												qGetProds.Basis_Code_Free_Goods,
												qGetProds.Effective_Margin_Percent,
												qGetProds.Scan_Volume
												); --->
							<cftry>
								<cfscript>
										aCompVal = rate.set(
													rebate_rate,
													uom,
													qGetProds.Program_Rebates_Component_ID,
													conProdID,
													qGetProds.Program_Rebates_Component_Rule_ID,
													qGetProds.Basis_Code_Quantity,
													qGetProds.Basis_Code_Quantity_UOM,
													qGetProds.Basis_Code_Free_Goods,
													qGetProds.Effective_Margin_Percent,
													qGetProds.Scan_Volume,
													qGetProds.Program_Rebates_Component_Data_ID,
                          							qGetProds.EZ_Contract_Max_Rate,
                          							thisItemMasterId
													);
								</cfscript>

									<cfcatch type="any">
										<cfrethrow>
											<cfoutput>#rebate_rate# ::rate<br>
														#qGetProds.Program_Rebates_Component_ID# :: comp_id<br>
														#unit_of_measure_id# ::uom<br>
														#conProdID# ::conprod<br>
														#prodCounter# ::prodcount<br>
														#compCounter# ::compcount<br>
														#cfcatch.message#<br>
														#cfcatch.detail#<br><br>
																#rebate_rate#,
																#unit_of_measure_id#,
																#qGetProds.Program_Rebates_Component_ID#,
																#conProdID#,
																#qGetProds.Program_Rebates_Component_Rule_ID#,
																#qGetProds.Basis_Code_Quantity#,
																#qGetProds.Basis_Code_Quantity_UOM#,
																#qGetProds.Basis_Code_Free_Goods#,
																#qGetProds.Effective_Margin_Percent#,
																#qGetProds.Scan_Volume#</cfoutput>
									</cfcatch>
							</cftry>

							<cfset this.stRebate.aCompVal[prodCounter][compCounter] = aCompVal />
					</CFIF>
		</cfloop>

			<!---set rebate calculations if we have any--->
	<!--- 		<cfscript>

				aRebateValue = ArrayNew(1);
				tmpReb1 = createObject("component","components.programs.rebates.Rebate");
				aRebateValue = tmpReb1.calculate(this.stRebate.aProd,this.stRebate.aComp,this.stRebate.aCompVal);

				for(i=1; i lte ArrayLen(this.stRebate.aProd); i = i+1)
				{
					this.stRebate.aProd[i].rebateVal = aRebateValue[i].rebateVal;
				}

			</cfscript> --->

			<!---set the program id--->
			<cfscript>
				this.stRebate.programID = arguments.programID;
			</cfscript>

		<cfif arguments.EZTemplate EQ 0 and arguments.useXML eq 1>
			<cfwddx action="cfml2wddx" input="#this.stRebate#" output="tmp1DataPacket">

			<cftry>

				<cflock timeout="10" type="exclusive">
				<cffile action="write" file="#request.app_general_functions.Get_Document_Path()#\data_files\created\contracts\RebateData\#this.stRebate.programID#.xml" output="#tmp1DataPacket#">
				</cflock>

			<cfcatch type="any">
				<cfoutput><b>#cfcatch.Detail#</b></cfoutput>
			</cfcatch>

			</cftry>
		</cfif>
		<cfelse>


			<!---read data in from file and set the values before modifying the data structure--->
			<cffile action="read" file="#request.app_general_functions.Get_Document_Path()#\data_Files\created\contracts\RebateData\#arguments.programID#.xml" variable="loadRebData">
			<cfwddx action="wddx2cfml" input="#loadRebData#" output="thisRebateData" />
			<cfset this.stRebate = thisRebateData />
			<!---
				<cfloop from="1" to="#ArrayLen(this.stRebate.aProd)#" index="ProductNumber">
				<cfset ContractDates = getContractDates(this.stRebate.aProd[ProductNumber].MasterItemID,arguments.ProgramID,arguments.IsParent)>
					<cfset this.stRebate.aProd[ProductNumber].Contract_Start_Date
					 = ContractDates.Contract_Start_Date>
					<cfset this.stRebate.aProd[ProductNumber].Contract_End_Date
					 = ContractDates.Contract_End_Date>
				</cfloop>
			--->
		</cfif>


		<cfreturn this.stRebate />

 	</cffunction>

	<cffunction name="update" output="false" returntype="struct" hint="Method updates the WDDX packet with what's in the form scope to maintain state." displayname="update">

		<cfargument name="programID" type="numeric" required="true" default="" />
		<cfargument name="aProd" type="array" required="false" default="this.stRebate.aProd" />
		<cfargument name="aComp" type="array" required="false" default="this.stRebate.aComp" />
		<cfargument name="aCompVal" type="array" required="false" default="this.stRebate.aCompVal" />
		<cfargument name="form" required="false" default="" />
		<cfargument name="aGroupLevel" type="array" required="false" default="#this.stRebate.aGroupLevel#" />
		<cfargument name="action" required="false" default="" /><!--- if action = "updSave" then we write the Updated rates (from the form scope) to the DB --->
		<cfset var arUpdSave = arrayNew(1) />
		<cfset this.stRebate.programID = arguments.programID />
		<cfset this.stRebate.aComp = arguments.aComp />
		<cfset this.stRebate.aGroupLevel = arguments.aGroupLevel />

		<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
		<cfset paymentCycleManager = createObject("component","components.programs.PaymentCycleManager").init() />

		<!---if we have components and products then lets grab component data from the form fields and set it in the wddx packet--->
		<cfif ArrayLen(arguments.aProd) and ArrayLen(arguments.aComp) and isDefined("arguments.form.bGetFromForm")>

			<cfset initialiseGroupLevel() />
			<!--- 34678 - When product count is more than 800 we divide products into multiple pages.
			      Therefore only a portion of the big products array is displayed on the page.
			      Filter array elements based on form.startRow and form.endRow (defined in \common_Files\contracts\_rebates_components.cfm) --->
			<cfparam name="arguments.form.startRow" default="1">
			<cfparam name="arguments.form.endRow"   default="#ArrayLen(arguments.aProd)#">
			<cfset arguments.form.endRow = min(arguments.form.endRow, ArrayLen(arguments.aProd))>

			<cfscript>

				//start loop through the product array first
				for (i = arguments.form.startRow; i lte arguments.form.endRow; i = i+1)
				{
								//strip hyphens from prod id to use as attribute
								prodIdVarName = request.app_general_functions.replaceHyphen(arguments.aProd[i].masterItemID);

								if(isDefined("arguments.form.Product_Group_ID_#prodIdVarName#"))
								{
									arguments.aProd[i].productGroupID = Evaluate("arguments.form.Product_Group_ID_#prodIdVarName#");
								}

								if(isDefined("arguments.form.Product_Group_Level_ID_#prodIdVarName#"))
								{
									arguments.aProd[i].productGroupLevel = Evaluate("arguments.form.Product_Group_Level_ID_#prodIdVarName#");
								}

								if(isDefined("arguments.form.Pricing_Level_ID_#prodIdVarName#"))
								{
									arguments.aProd[i].pricingLevel = Evaluate("arguments.form.Pricing_Level_ID_#prodIdVarName#");
								}

								if(isDefined("arguments.form.Is_Group_#prodIdVarName#"))
								{
									arguments.aProd[i].isGroup = Evaluate("arguments.form.Is_Group_#prodIdVarName#");
								}

								if(isDefined("arguments.form.Product_Group_Level_Type_ID_#prodIdVarName#"))
								{
									arguments.aProd[i].productGroupLevelTypeId = Evaluate("arguments.form.Product_Group_Level_Type_ID_#prodIdVarName#");

								}

								if(isDefined("arguments.form.groupNumber_#prodIdVarName#"))
								{
									arguments.aProd[i].groupNumber = Evaluate("arguments.form.groupNumber_#prodIdVarName#");
								}


								//set values in the product object to form variable values
								if(not isDefined("arguments.form.volume_#i#"))
								{
									arguments.aProd[i].volume = 0.000;
								}
								else
								{
									arguments.aProd[i].volume = Evaluate("arguments.form.volume_#i#");
								}

								if (not isDefined("arguments.form.PROD_DEFAULT_#prodIdVarName#") )
								{
									arguments.aProd[i].EZButton_On_Default = 0;
								}
								else
								{
									arguments.aProd[i].EZButton_On_Default = Evaluate("arguments.form.PROD_DEFAULT_#prodIdVarName#");
								}

								addToGroupLevel(arguments.aProd[i].productGroupLevelTypeId, arguments.aProd[i].pricingLevel);

							//then loop through the component array
							for (n = 1; n lte ArrayLen(arguments.aComp); n = n+1)
							{
												//set prod and comp var names
												compIdVarName = request.app_general_functions.replaceHyphen(arguments.aComp[n].compUUID);

												//guard against form fields not being defined when adding products and components
												//if (not isDefined("arguments.form.comp_rate_#Replace(arguments.aProd[i].masterItemID, "-", "_", "ALL")#_#Replace(arguments.aComp[n].compUUID,"-","_","ALL")#") )
												if (not isDefined("arguments.form.comp_rate_#prodIdVarName#_#compIdVarName#") )
													{
														"arguments.form.comp_rate_#prodIdVarName#_#compIdVarName#" = arguments.aCompVal[i][n].rate;
													}

												//if (not isDefined("arguments.form.uom_#Replace(arguments.aProd[i].masterItemID, "-", "_", "ALL")#_#Replace(arguments.aComp[n].compUUID,"-","_","ALL")#"))
												if (not isDefined("arguments.form.uom_#prodIdVarName#_#compIdVarName#"))
													{
														"arguments.form.uom_#prodIdVarName#_#compIdVarName#" = arguments.aCompVal[i][n].uomId;
													}
												if (not isDefined("arguments.form.comp_scan_volume_#prodIdVarName#_#compIdVarName#") )
												{
													"arguments.form.comp_scan_volume_#prodIdVarName#_#compIdVarName#" = arguments.aCompVal[i][n].scanVolume;
												}

												//guard against rebate rule being undefined
												if (not isDefined("arguments.form.reb_rule_#prodIdVarName#_#compIdVarName#"))
												{
													"arguments.form.reb_rule_#prodIdVarName#_#compIdVarName#" = 0;
												}

												if (not isDefined("arguments.form.comp_basis_code_quantity_#prodIdVarName#_#compIdVarName#") )
												{
													"arguments.form.comp_basis_code_quantity_#prodIdVarName#_#compIdVarName#" = arguments.aCompVal[i][n].basisCodeQuantity;
												}

												if (not isDefined("arguments.form.comp_basis_code_quantity_uom_#prodIdVarName#_#compIdVarName#") )
												{
													"arguments.form.comp_basis_code_quantity_uom_#prodIdVarName#_#compIdVarName#" = arguments.aCompVal[i][n].basisCodeQuantityUom;
												}

												if (not isDefined("arguments.form.comp_basis_code_free_goods_#prodIdVarName#_#compIdVarName#") )
												{
													"arguments.form.comp_basis_code_free_goods_#prodIdVarName#_#compIdVarName#" = arguments.aCompVal[i][n].basisCodeFreeGoods;
												}

												if (not isDefined("arguments.form.comp_effective_margin_percent_#prodIdVarName#_#compIdVarName#") )
												{
													"arguments.form.comp_effective_margin_percent_#prodIdVarName#_#compIdVarName#" = arguments.aCompVal[i][n].effectMarginPercent;
												}


									if (not isDefined("arguments.form.Competitor_Price_#prodIdVarName#") )
									{
										if(structkeyexists(arguments.aCompVal[i][n],'Competitor_Price')){
											"arguments.form.Competitor_Price_#prodIdVarName#" = arguments.aCompVal[i][n].Competitor_Price;
											"arguments.form.Competitor_Name_ID_#prodIdVarName#" = arguments.aCompVal[i][n].Competitor_Name_ID;
											"arguments.form.Competitor_Time_Frame_#prodIdVarName#" = arguments.aCompVal[i][n].Competitor_Time_Frame;
											"arguments.form.CompetitorSourceOther_#prodIdVarName#" = arguments.aCompVal[i][n].CompetitorSourceOther;
										}
										else{
											"arguments.form.Competitor_Price_#prodIdVarName#" = 0;
											"arguments.form.Competitor_Name_ID_#prodIdVarName#" = 0;
											"arguments.form.Competitor_Time_Frame_#prodIdVarName#" = '';
											"arguments.form.CompetitorSourceOther_#prodIdVarName#" = '';
										}

									}

						// D38536  :: Alternate recapture rates per component START
							for (j = 1; j  lte arguments.aComp[n].alternate_recapture_rate; j = j+1){
										arguments.aCompVal[i][n].ar_rate[j] =Evaluate("arguments.form.arr_#j#_#prodIdVarName#_#compIdVarName#");
										arguments.aCompVal[i][n].ar_uom[j] =Evaluate("arguments.form.arr_#j#_uom_#prodIdVarName#_#compIdVarName#");
								}
						// D38536  :: Alternate recapture rates per component END

						arguments.aCompVal[i][n].rate = Evaluate("arguments.form.comp_rate_#prodIdVarName#_#compIdVarName#");
						arguments.aCompVal[i][n].uomId = Evaluate("arguments.form.uom_#prodIdVarName#_#compIdVarName#");
						arguments.aCompVal[i][n].compId = arguments.aCompVal[i][n].compId;
						arguments.aCompVal[i][n].contractProdId = arguments.aCompVal[i][n].contractProdId;
						arguments.aCompVal[i][n].ruleId = Evaluate("arguments.form.reb_rule_#prodIdVarName#_#compIdVarName#");
						arguments.aCompVal[i][n].scanVolume = Evaluate("arguments.form.comp_scan_volume_#prodIdVarName#_#compIdVarName#");

						arguments.aCompVal[i][n].basisCodeQuantity = Evaluate("arguments.form.comp_basis_code_quantity_#prodIdVarName#_#compIdVarName#");
						arguments.aCompVal[i][n].basisCodeQuantityUom = Evaluate("arguments.form.comp_basis_code_quantity_uom_#prodIdVarName#_#compIdVarName#");
						arguments.aCompVal[i][n].basisCodeFreeGoods = Evaluate("arguments.form.comp_basis_code_free_goods_#prodIdVarName#_#compIdVarName#");
						arguments.aCompVal[i][n].effectMarginPercent = Evaluate("arguments.form.comp_effective_margin_percent_#prodIdVarName#_#compIdVarName#");

						arguments.aCompVal[i][n].Competitor_Price = Evaluate("arguments.form.Competitor_Price_#prodIdVarName#");
						arguments.aCompVal[i][n].Competitor_Name_ID = Evaluate("arguments.form.Competitor_Name_ID_#prodIdVarName#");
						arguments.aCompVal[i][n].Competitor_Time_Frame = Evaluate("arguments.form.Competitor_Time_Frame_#prodIdVarName#");
						arguments.aCompVal[i][n].CompetitorSourceOther = Evaluate("arguments.form.CompetitorSourceOther_#prodIdVarName#");
						// Competitor_Price Competitor_Name_ID Competitor_Time_Frame

						/*
						for scan components if the uom selected by the user is "each", we store the rate entered by the user in the scan rate field
						and will store the rate converted to product UOM in the regular rate fields so that we do not have to change the rest of the application for now.
						once we have logic to handle uom="each" in other parts of the app we can remove the following conversion.

						if rebate type = Variable/Fixed Combo and uom=EA
						*/
						scanRate = arguments.aCompVal[i][n].rate;
						scanUom = arguments.aCompVal[i][n].uomId;
						if(arguments.aComp[n].rebate_type == 4 && arguments.aCompVal[i][n].uomId == 5)
						{
							arguments.aCompVal[i][n].uomId = 1;
							if(arguments.aProd[i].productInventoryUOM == "LB")
							{
								arguments.aCompVal[i][n].uomId = 2;
							}
							arguments.aCompVal[i][n].rate = arguments.aCompVal[i][n].rate * arguments.aProd[i].EAConversion;
						}

						if (action == "updSave")
						{
							arUpdSave[1] = arguments.aCompVal[i][n].rate;
							arUpdSave[2] = arguments.aCompVal[i][n].uomId;
							arUpdSave[3] = arguments.aCompVal[i][n].Program_Rebates_Component_Data_ID; //do not need form field since this is hidden we know it is in struct
							// pass scan volume D17948
							if(arguments.aComp[n].rebate_type EQ 4)
							{
								arUpdSave[6] = arguments.aCompVal[i][n].scanVolume;
								arUpdSave[8] = scanRate;
								arUpdSave[9] = scanUom;
							}
							else
							{
								arUpdSave[6] = "";
								arUpdSave[8] = "";
								arUpdSave[9] = "";
							}
							arUpdSave[7] = arguments.aCompVal[i][n].ruleId;
							arUpdSave[10] = arguments.aCompVal[i][n].Competitor_Price;
							arUpdSave[11] = arguments.aCompVal[i][n].Competitor_Name_ID;
							arUpdSave[12] = arguments.aCompVal[i][n].Competitor_Time_Frame;
							arUpdSave[13] = arguments.aCompVal[i][n].CompetitorSourceOther;
							// D38536  :: Alternate recapture rates per component START
							arUpdSave[14] = arguments.aComp[n].alternate_recapture_rate;
							arUpdSave[15] = arguments.aCompVal[i][n].contractprodid;
							arUpdSave[16] = arguments.aCompVal[i][n].ar_rate;
							arUpdSave[17] = arguments.aCompVal[i][n].ar_uom;
							arUpdSave[18] = arguments.aComp[n].compnameid;
							// D38536  :: Alternate recapture rates per component END
							this.saveProdRate(arUpdSave, 1);
						}

					}

				}


				// loop through the component array to save the values into the db
				// this save loop is outside the above product/component loop because we do not want to save the component informaton when we loop over each product
				// above loop is "component loop inside product loop"
				// if if ever change it to be "component loop outside product loop" at that time below code to save can be moved to above component loop.
				paymentCycleManager.DeletePaymentCycle(arguments.programId, 2);
				for (n = 1; n lte ArrayLen(arguments.aComp); n = n+1)
				{
					//set the comp name to what's in the form scope if it's defined
					if (isDefined("arguments.form.compNameId_#n#"))
						{
							this.stRebate.aComp[n].compNameId = Evaluate("arguments.form.compNameId_#n#");
						}
					if (isDefined("arguments.form.compPaidTo_#n#"))
						{
							this.stRebate.aComp[n].componentPaidTo = Evaluate("arguments.form.compPaidTo_#n#");
						}
					if (isDefined("arguments.form.GL_Account_ID_#n#"))
						{
							this.stRebate.aComp[n].GL_Account_ID = Evaluate("arguments.form.GL_Account_ID_#n#");
						}
					if (isDefined("arguments.form.Vendor_Master_ID_#n#"))
						{
							this.stRebate.aComp[n].Vendor_Master_ID = Evaluate("arguments.form.Vendor_Master_ID_#n#");
						}
					if (isDefined("arguments.form.VendorSelection_#n#"))
						{
							this.stRebate.aComp[n].VendorSelection = Evaluate("arguments.form.VendorSelection_#n#");
						}
					if (isDefined("arguments.form.PaymentCycle_#n#"))
						{
							this.stRebate.aComp[n].PaymentCycle = Evaluate("arguments.form.PaymentCycle_#n#");
						}
					if (isDefined("arguments.form.Claim_Mechanics_#n#"))
						{
							this.stRebate.aComp[n].Claim_Mechanics = Evaluate("arguments.form.Claim_Mechanics_#n#");
						}
					if (isDefined("arguments.form.Payee_Selection_#n#"))
						{
							this.stRebate.aComp[n].Payee_Selection = Evaluate("arguments.form.Payee_Selection_#n#");
						}
					/*if (isDefined("arguments.form.Component_Type_#n#"))
					{
						this.stRebate.aComp[n].componentType = Evaluate("arguments.form.Component_Type_#n#");
					}*/
					this.saveComponentInformation(this.stRebate.aComp[n]);
					if(appSettings.getPaymentCycleAtDiscountType() AND len(trim(this.stRebate.aComp[n].PaymentCycle)))
					{
						paymentCycleManager.savePaymentCycle(arguments.programId, 2, this.stRebate.aComp[n].PaymentCycle, this.stRebate.aComp[n].compID);
					}
				}
			</cfscript>

		<!---if we have just products--->
		<cfelseif ArrayLen(arguments.aProd) and not ArrayLen(arguments.aComp)>

			<cfscript>

				//start loop through the product array first
				for (i = 1; i lte ArrayLen(arguments.aProd); i = i+1)
				{
					//strip hyphens from prod id to use as attribute
					prodIdVarName = request.app_general_functions.replaceHyphen(arguments.aProd[i].masterItemID);

					if(isDefined("arguments.form.Product_Group_ID_#prodIdVarName#"))
					{
						arguments.aProd[i].productGroupID = Evaluate("arguments.form.Product_Group_ID_#prodIdVarName#");
					}

					if(isDefined("arguments.form.Product_Group_Level_ID_#prodIdVarName#"))
					{
						arguments.aProd[i].productGroupLevel = Evaluate("arguments.form.Product_Group_Level_ID_#prodIdVarName#");
					}

					if(isDefined("arguments.form.Pricing_Level_ID_#prodIdVarName#"))
					{
						arguments.aProd[i].pricingLevel = Evaluate("arguments.form.Pricing_Level_ID_#prodIdVarName#");
					}

					if(isDefined("arguments.form.Is_Group_#prodIdVarName#"))
					{
						arguments.aProd[i].isGroup = Evaluate("arguments.form.Is_Group_#prodIdVarName#");
					}

					if(isDefined("arguments.form.Product_Group_Level_Type_ID_#prodIdVarName#"))
					{
						arguments.aProd[i].productGroupLevelTypeId = Evaluate("arguments.form.Product_Group_Level_Type_ID_#prodIdVarName#");
					}

					//set values in the product object to form variable values
					if(not isDefined("arguments.form.volume_#i#"))
					{
						arguments.aProd[i].volume = 0.000;
					}
					else
					{
						arguments.aProd[i].volume = Evaluate("arguments.form.volume_#i#");
					}
				}
			</cfscript>

		<!---if we have just components--->
		<cfelseif not ArrayLen(arguments.aProd) and ArrayLen(arguments.aComp)>

			<cfscript>

				//then loop through the component array
				paymentCycleManager.DeletePaymentCycle(arguments.programId, 2);
				for (n = 1; n lte ArrayLen(arguments.aComp); n = n+1)
				{
					//set the comp name to what's in the form scope if it's defined
					if (isDefined("arguments.form.compNameId_#n#"))
					{
						this.stRebate.aComp[n].compNameId = Evaluate("arguments.form.compNameId_#n#");
					}

					if (isDefined("arguments.form.compPaidTo_#n#"))
						{
							this.stRebate.aComp[n].componentPaidTo = Evaluate("arguments.form.compPaidTo_#n#");
						}
					if (isDefined("arguments.form.PaymentCycle_#n#"))
						{
							this.stRebate.aComp[n].PaymentCycle = Evaluate("arguments.form.PaymentCycle_#n#");
						}
					if (isDefined("arguments.form.Vendor_Master_ID_#n#"))
						{
							this.stRebate.aComp[n].Vendor_Master_ID = Evaluate("arguments.form.Vendor_Master_ID_#n#");
						}
					if (isDefined("arguments.form.VendorSelection_#n#"))
						{
							this.stRebate.aComp[n].VendorSelection = Evaluate("arguments.form.VendorSelection_#n#");
						}
					if (isDefined("arguments.form.GL_Account_ID_#n#"))
						{
							this.stRebate.aComp[n].GL_Account_ID = Evaluate("arguments.form.GL_Account_ID_#n#");
						}
					if (isDefined("arguments.form.Claim_Mechanics_#n#"))
						{
							this.stRebate.aComp[n].Claim_Mechanics = Evaluate("arguments.form.Claim_Mechanics_#n#");
						}
					if (isDefined("arguments.form.Payee_Selection_#n#"))
						{
							this.stRebate.aComp[n].Payee_Selection = Evaluate("arguments.form.Payee_Selection_#n#");
						}
					//guard against form fields not being defined when adding products and components
					if (arrayLen(arguments.aCompVal))
						{
							if (not isDefined("arguments.form.comp_rate_#n#") )
							{
									"arguments.form.comp_rate_#n#" = arguments.aCompVal[n].rate;
							}

							if (not isDefined("arguments.form.uom_#n#"))
							{
								"arguments.form.uom_#n#" = arguments.aCompVal[n].uomId;
							}

							arguments.aCompVal[n].rate = Evaluate("arguments.form.comp_rate_#n#");
							arguments.aCompVal[n].uomId = Evaluate("arguments.form.uom_#n#");
							arguments.aCompVal[n].compId = arguments.aCompVal[n].compId;
							arguments.aCompVal[n].contractProdId = arguments.aCompVal[n].contractProdId;
						}

					//// save component information into the database
					this.saveComponentInformation(this.stRebate.aComp[n]);
					if(appSettings.getPaymentCycleAtDiscountType() AND len(trim(this.stRebate.aComp[n].PaymentCycle)))
					{
						paymentCycleManager.savePaymentCycle(arguments.programId, 2, this.stRebate.aComp[n].PaymentCycle, this.stRebate.aComp[n].compID);
					}
				}

			</cfscript>

		</cfif>



		<cfset this.stRebate.aProd = arguments.aProd />
		<cfset this.stRebate.aCompVal = arguments.aCompVal />

		<cfset UpdStatus = UpdateGroupStatus('#arguments.programID#')>
<!--- 	<cfif ArrayLen(this.stRebate.aComp) and ArrayLen(this.stRebate.aCompVal)>

			<!---set rebate calculations if we have any--->
			<cfscript>

				aRebateValue = ArrayNew(1);
				tmpReb1 = createObject("component","components.programs.rebates.Rebate");
				aRebateValue = tmpReb1.calculate(this.stRebate.aProd,this.stRebate.aComp,this.stRebate.aCompVal);

				for(i=1; i lte ArrayLen(this.stRebate.aProd); i = i+1)
				{
					this.stRebate.aProd[i].rebateVal = aRebateValue[i].rebateVal;
				}

			</cfscript>

		</cfif> --->

		<cfreturn this.stRebate />

	</cffunction>

	<cffunction name="getWddxDataFromFile" output="false" returntype="struct">

		<cfargument name="fileName" required="false" default="" />

		<!---read data in from file and set the values before modifying the data structure--->
		<!--- <cffile
			action="read"
			file="#this.tmpFilePath#\#arguments.fileName#"
			variable="rebateData">

		<cfwddx action="wddx2cfml" input="#rebateData#" output="desRebateData" /> --->
		<cfscript>
			rebate = createObject("component","components.programs.rebates.Rebate");
			rebateData = rebate.loadFromDB(programID=arguments.programID,displayGroupType=arguments.displaygrouptype,useXML=0);
			//rebate.updateWddxDataFile(rebateData,arguments.fileName);
		</cfscript>
		<!--- <cfreturn desRebateData/> --->
		<cfreturn rebateData />

	</cffunction>

	<cffunction name="updateWddxDataFile" output="false" returntype="struct">

		<cfargument name="rebDataPacket" type="struct" required="false" default="" />
		<cfargument name="fileName" required="false" default="" />

		<!---dump data into wddx and pump it out to a file--->
		<!--- <cfwddx action="cfml2wddx" input="#arguments.rebDataPacket#" output="wddxPacket">

		<cftry>

			<!--- <cflock name="rebateFile" timeout="10" throwontimeout="Yes" type="EXCLUSIVE"> --->

				<cffile
					action="write"
					file="#this.tmpFilePath#\#arguments.fileName#"
					output="#wddxPacket#"
					addnewline="no">

			<!--- </cflock> --->

		<cfcatch type="any">
			<cfoutput><b>#cfcatch.Detail#</b></cfoutput>
		</cfcatch>

		</cftry>  --->

		<cfreturn arguments.rebDataPacket />

	</cffunction>

	<cffunction name="deleteWddxDataFile" output="false" returntype="boolean">

		<cfargument name="fileName" required="false" default="" />

			<!--- <cftry>

				<cffile
					action="delete"
					file="#this.tmpFilePath#\#arguments.fileName#">

			<cfreturn true />

			<cfcatch type="any">

				<cfreturn false />

			</cfcatch>

			</cftry> --->
			<cfreturn true />
	</cffunction>

	<cffunction name="addProd" output="true" returntype="struct">

		<cfargument name="stDataStructure" type="struct" required="true" default="" />
		<cfargument name="lProdList" required="true" default="" />
		<cfargument name="contractMainID" required="true" default="" />
		<cfargument name="group_rebate_type_search_id" required="false" default="" />
		<cfargument name="level3List" type="string" required="false" default="" />
		<cfargument name="displaygrouptype" required="false" default="0" />
		<cfargument name="EZTemplate" required="false" default="0">
 		<cfargument name="EZ_Contract_ID" required="false" default="0">
		<cfargument name="EZMaxRateOn" required="false" default="0">


		<!---create instances of components--->
		<cfscript>
			var aProdCopy = Duplicate(arguments.stDataStructure.aProd);
			product = createObject("component","components.programs.rebates.Product");
			contract = CreateObject("component", "components.programs.rebates.Contract");
			contractUom = contract.get(arguments.contractMainID);
			contractQty = Val(contractUom.Contract_Quantity);
		if (arguments.EZTemplate)
		{
			contractSpan = 0;
			weeklyQty = 0;
		}
		else
		{
			contractSpan = DateDiff("d", contractUom.Contract_Start_Date, contractUom.Contract_End_Date) + 1;
			weeklyQty = (contractQty * 7) / contractSpan;
		}
		</cfscript>

		<!---we have components but don't have products--->
		<cfif not ArrayLen(arguments.stDataStructure.aProd) and ArrayLen(arguments.stDataStructure.aComp)>

			<cfscript>

				//compValCopy =  duplicate(arguments.stDataStructure.aCompVal);
				//create an empty shell
				compValCopy[1]= rate.set(
													0,
													1,
													0,
													0,
													0,
													0,
													0,
													0,
													0,
													0,
													0
													);
				noProducts = true;

			</cfscript>

		</cfif>

		<!---we have components and products--->
		<cfif ArrayLen(arguments.stDataStructure.aProd) and ArrayLen(arguments.stDataStructure.aComp)>

			<cfscript>

				lastCompValCopy =  duplicate(arguments.stDataStructure.aCompVal[1]);
				contract = CreateObject("component", "components.programs.rebates.Contract");
				contractUom = contract.get(arguments.contractMainID);
				tmpUSDAComp = createObject("component","components.programs.rebates.RebateComponent");

				for (i=1; i lte ArrayLen(lastCompValCopy); i = i+1)
				{
					lastCompValCopy[i].rate = 0.000;
					lastCompValCopy[i].uomId = contract.getDefaultUom(arguments.contractMainID);
				}

				hasProducts = true;

			</cfscript>

		</cfif>
		<!------ Get pricing level descriptions ----->
		<cfset qGetPricingLevel = this.GroupDataManager.getPricingLevel() />
		<cfset arPricingLevel = ListToArray(ValueList(qGetPricingLevel.Pricing_Level_Desc, ","), ",") />
		<cfset arPricingLevelLen = ArrayLen(arPricingLevel) />

		<!------ As there variable are not going to chnaged, moved outside the loop ----->
		<cfparam name="form.Level_1" default="" />
		<cfparam name="form.Level_2" default="" />
		<cfparam name="form.Level_3" default="" />

		<cfset defaultLevelForProducts = 0 />
		<!---run logic to determine which level to put the products in--->
		<!---handle for level 1--->
		<cfif (trim(form.Level_1) eq "" and trim(form.Level_2) eq "") or trim(form.GroupLevel_1) eq 9>
			<cfset defaultLevelForProducts = 1 />
		<!---handle for level 2--->
		<cfelseif (trim(form.Level_1) neq "" and trim(form.Level_2) eq "") or trim(form.GroupLevel_2) eq 9>
			<cfset defaultLevelForProducts = 2 />
		<!---handle for level 3--->
		<cfelseif (trim(form.Level_1) neq "" and trim(form.Level_2) neq "") or trim(form.GroupLevel_3) eq 9>
			<cfset defaultLevelForProducts = 3 />
		</cfif>

		<!------
			Inorder to make sure that products in level 2 and level 3 are a sub set of Level 1
			- 	Product search is filtered against Level 1 using the input fields AllowProductGroupList and AllowProductGroupLevelId
			- 	But still user can select group, select product, then use scissors to change/delete the original group selection,
				in that case check this list while submitting the form
			----->

		<!--- Dev Note: Clay 8926 Events 2022, 2145 for ICM PRD
				There are cases when GroupLevel_1 is not defined.
				In the events, there were cases of form.level_1 and form.level_2 or form.grouplevel_2
				having a value but form.grouplevel1 being empty.
				This section of code will handle when logic from lines 715 - 724 execute and form.grouplevel_1 is null.
		  --->
		<cfif len(form.GroupLevel_1) EQ 0>
			<cfset form.GroupLevel_1 = 0 />
		</cfif>
		<!--- End Dev Note: Clay 8926 --->

		<cfset qProductGroupValuesForItem = QueryNew("Product_ID,Group_ID") />
		<cfif ListLen(arguments.lProdList) GT 0>
			<cfif defaultLevelForProducts GT 1><!------ Level 1 is group ----->
				<cfset productGroupAttributeManager 	= CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />
				<cfset productGroupType 				= productGroupAttributeManager.getGroupTypeInfo(groupLevelId=form.GroupLevel_1) />
				<cfset qProductGroupValuesForItem 		= productGroupAttributeManager.getProductGroupValuesForItem(
						productGroupType=productGroupType,
						productIDList	=arguments.lProdList) />
			</cfif>
		</cfif>

		<cfset originalCompVal = Duplicate(arguments.stDataStructure.aCompVal) />
		<cfset counter = 1 />
		<cfset qProgram = CreateObject("component", "components.programs.program").getProgramInfo(arguments.contractMainID) />
		<cfset tmpUSDAComp = createObject("component","components.programs.rebates.RebateComponent") />
		<cfset oPrdGrpDataManager = CreateObject("component", "components.products.Group.DataManager") />
		<cfloop index="prodID" list="#arguments.lProdList#">

			<!---strip hyphens--->
			<cfset prodIdNoHyphen = request.app_general_functions.replaceHyphen(prodID) />

			<cfparam name="form.Product_Group_Level_ID_#prodIdNoHyphen#" default="0" />
			<cfparam name="form.Product_Group_ID_#prodIdNoHyphen#" default="" />
			<cfparam name="form.Pricing_Level_ID_#prodIdNoHyphen#" default="0" />
			<cfparam name="form.Is_Group_#prodIdNoHyphen#" default="0" />
			<cfparam name="form.Product_Group_Level_Type_ID_#prodIdNoHyphen#" default="" />
			<cfparam name="form.Prod_Default_#prodIdNoHyphen#" default="0" />
<!--- 			<cfparam name="bIsProduct" default="" />

			<!---find out what group level this product is in. if the group level is 9 then we know it's a product--->
			<cfloop index="levelIndx" from="1" to="3">
				<cfif ListFindNoCase(Evaluate("form.Level_#levelIndx#"), prodID)>
					<cfset bIsProduct = Evaluate("form.GroupLevel_#levelIndx#") />
				</cfif>
			</cfloop> --->

			<!--- <cfset qProductGroupLevel = ProductGroupManager.getGroupFromProduct(prodID, 1) />

			<cfset productGroupLevel 	= qProductGroupLevel.Product_Group_Level_ID>
			<cfset productGroupID 		= qProductGroupLevel.Product_Group_ID> --->
			<cfset productGroupLevel 	= 0>
			<cfset productGroupID 		= 0>

			<cfset this.Inventory_UM 	= "" />
			<cfset this.EAConversion = 1 />

			<!---this is for adding just straight products--->
			<cfif productGroupLevel EQ 0 and Evaluate("form.Is_Group_#prodIdNoHyphen#") neq 1>

				<cfquery name="qGetProduct" datasource="#application.datasource#">
					SELECT 	item,
							upc,
							description,
							Inventory_UM,
							ISNULL(BSA_Foodservice_Items_Master.EA_Conversion, 1) as EA_Conversion,
							BSA_Foodservice_Items_Master.Type_Code_Desc_ID,
							Net_weight
					FROM 	BSA_Foodservice_Items_Master
					WHERE	BSA_Foodservice_Items_Master_ID = '#prodID#'
					AND		deleted = 0
				</cfquery>

				<cfset this.item = qGetProduct.item />
				<cfset this.upc = qGetProduct.upc />
				<cfset this.description = qGetProduct.description />
				<cfset this.Inventory_UM = qGetProduct.Inventory_UM />
				<cfset this.EAConversion = qGetProduct.EA_Conversion />
				<cfset this.Type_Code_Desc_ID = qGetProduct.Type_Code_Desc_ID />
				<cfset this.Net_weight= qGetProduct.Net_weight />

				<cfif arguments.EZTemplate EQ 0>
				<!--- <cfset thisProductVolume = ProductGroupManager.getPerProductVolume(arguments.contractMainID, qProgram) /> LEGACY CODE?--->
					<cfset thisProductVolume = 0 />
				<cfelse>
					<cfset thisProductVolume = 0>
				</cfif>

				<!--- The level for products is already determined above, use it now --->
				<cfset "form.Pricing_Level_ID_#prodIdNoHyphen#" = defaultLevelForProducts />
				<!------ In the case of where products can be part of 2 levels, use arguments.level3List to determine if we should put this is level3 instea dof level2 ----->
				<cfif defaultLevelForProducts EQ 2>
					<cfif ListFind(arguments.level3List, prodID, ",")>
						<cfset "form.Pricing_Level_ID_#prodIdNoHyphen#" = 3 />
					</cfif>
				</cfif>

				<cfset "form.Product_Group_Level_ID_#prodIdNoHyphen#" = 9 />
				<cfset "form.Product_Group_Level_Type_ID_#prodIdNoHyphen#" = 0 />

			<!---this is for adding product groups--->
			<cfelseif Evaluate("form.Is_Group_#prodIdNoHyphen#") eq 1 and Evaluate("form.Product_Group_Level_Type_ID_#prodIdNoHyphen#") neq 1>

				<cfif (arguments.contractMainID NEQ 0 AND arguments.contractMainID NEQ "")>
					<cfquery name="GetContractInfo" Datasource="#application.datasource#">
						SELECT *
						FROM Contract_Main
						WHERE Contract_Main_ID = #arguments.contractMainID#
					</cfquery>

					<cfquery name="GetTemplateInfo" datasource="#application.datasource#">
						SELECT First_parent_ID
				    FROM Program_Control_Panel_Options
				    WHERE ProgramControl_Panel_Options_ID = #GetContractInfo.ProgramType_ID#
				  </cfquery>
				</cfif>

				<cfif isDefined("GetTemplateInfo") AND GetTemplateInfo.RecordCount GTE 1>
					<cfset FirstParentID = GetTemplateInfo.First_parent_ID />
				<cfelse>
					<cfset FirstParentID = 0 />
				</cfif>

				<cfset qGetGroupProd = oPrdGrpDataManager.getByProductGroupData(
					prodGroupLevelId = Evaluate("form.Product_Group_Level_ID_#prodIdNoHyphen#"),
					prodGroupId = Evaluate("form.Product_Group_ID_#prodIdNoHyphen#"),
					programId = arguments.contractMainID,
					FirstParentID = FirstParentID)
				/>

				<cfset this.item = "" />
				<cfset this.upc = "Group Product" />
				<cfset this.description = qGetGroupProd.Group_Level_Desc />
				<cfset this.Type_Code_Desc_ID = "" />
				<cfset thisProductVolume = "" />
				<cfset this.Net_weight = 0 />
				<cfif qGetGroupProd.Product_Group_Level_Type EQ 2>
						<cfif qGetGroupProd.Unit_Of_Measure_ID EQ 1>
							<cfset this.Inventory_UM	=	"CS" />
						<cfelseif qGetGroupProd.Unit_Of_Measure_ID EQ 2>
							<cfset this.Inventory_UM	=	"LB" />
						</cfif>
				</cfif>

			<cfelse>

				<cfset qGetProduct = ProductGroupManager.getProductGroupDetails(productGroupLevel, productGroupID) />

				<cfset this.item = qGetProduct.item />
				<cfset this.upc = qGetProduct.upc />
				<cfset this.description = qGetProduct.description />
				<cfset this.Type_Code_Desc_ID = "" />
				<cfset thisProductVolume = weeklyQty />
				<cfset this.Net_weight = 0 />
			</cfif>

			<cfset productGroupLevel = Evaluate("form.Product_Group_Level_ID_#prodIdNoHyphen#") />
			<cfset productGroupID = Evaluate("form.Product_Group_ID_#prodIdNoHyphen#") />
			<cfset priceLevelId = Evaluate("form.Pricing_Level_ID_#prodIdNoHyphen#") />
			<cfset isGroup = Evaluate("form.Is_Group_#prodIdNoHyphen#") />
			<cfset productGroupLevelTypeId = Evaluate("form.Product_Group_Level_Type_ID_#prodIdNoHyphen#") />
			<cfset EZ_Prod_Default = Evaluate("form.Prod_Default_#prodIdNoHyphen#") />
			<cfset pricingLevelDesc = "" />
			<cfif priceLevelId GT 0 AND priceLevelId LTE arPricingLevelLen>
				<cfset pricingLevelDesc = arPricingLevel[priceLevelId] />
			</cfif>
 			<cfif productGroupLevel EQ "">
				<cfset productGroupLevel = "0" />
			</cfif>
			<cfset addToGroupLevel(groupLevelId = productGroupLevel, pricingLevelId = priceLevelId) />
			<!---if we don't have products--->

			<cfscript>

				if(product.checkExists(aProdCopy,prodID)){
					try{
					Competitor_Name_ID = Evaluate("form.Competitor_Name_ID_#prodIdNoHyphen#");
					Competitor_Price = Evaluate("form.Competitor_Price_#prodIdNoHyphen#");
					Competitor_Time_Frame = Evaluate("form.Competitor_Time_Frame_#prodIdNoHyphen#");
					}
					catch(Any e){
						Competitor_Name_ID = 0;
						Competitor_Price = 0;
						Competitor_Time_Frame = '';
					}
				}
				else{
					Competitor_Name_ID = 0;
					Competitor_Price = 0;
					Competitor_Time_Frame = '';
				}

					arguments.stDataStructure.aProd[counter] = product.set('',
																		prodID,
																		arguments.contractMainID,
																		2,
																		thisProductVolume,
																		this.item,
																		this.upc,
																		this.description,
																		this.Inventory_UM,
																		this.EAConversion,
																		"",
																		this.Net_weight,
																		productGroupLevel,
																		productGroupID,
																		priceLevelId,
																		pricingLevelDesc,
																		isGroup,
																		productGroupLevelTypeId,
																		"",
																		arguments.displaygrouptype,
																		this.Type_Code_Desc_ID,
																		qProductGroupValuesForItem,
																		EZ_Prod_Default,
									                                    '',
									                                    '',
									                                    arguments.EZ_Contract_ID,
									                                    0,
									                                    0,
									                                    Competitor_Name_ID,
																		Competitor_Price,
																		Competitor_Time_Frame
																		);
				//	}

					//if we have components in the array then we have to spread the matrix

					if (ArrayLen(arguments.stDataStructure.aCompVal) and isDefined("noProducts"))
					{
						for (i=1; i lte ArrayLen(arguments.stDataStructure.aComp); i=i+1)
						{
							arguments.stDataStructure.aCompVal[counter] = compValCopy;
						}
					}
			</cfscript>

			<!---if we have products and components--->
			<cfif ArrayLen(arguments.stDataStructure.aProd) and ArrayLen(arguments.stDataStructure.aComp)><!--- isDefined("hasProducts") --->

				<!---create a copy of lastCompValCopy array--->
			<!--- 	<cfset tmpCompVal = Duplicate(lastCompValCopy) /> --->

				<cfloop index="compIndx" from="1" to="#ArrayLen(arguments.stDataStructure.aComp)#">
					<cfscript>
					//create an empty shell
					currentRate =    0;
					UOM = contract.getDefaultUom(arguments.contractMainID);
					maxRate = 0;

					if (arguments.EZ_Contract_Id NEQ 0 AND arguments.EZ_Contract_Id NEQ "")
					{	// addProd
						ezRate = getRebateProductComponentRate(
						            arguments.EZ_Contract_Id,
						            prodID,
						            arguments.stDataStructure.aComp[compIndx].compNameId,
						            arguments.stDataStructure.aComp[compIndx].componentPaidTo);

						if(!arguments.EZMaxRateOn){
							currentRate = ezRate.Rate;
						}
						UOM = ezRate.UOM;
						// D28783: Release 7 EZ Button Max Rate. We no longer need to store the max rate on the program, always use the max rate from the latest template
						maxRate = ezRate.rate;
					}

					if (NOT isdefined("lastCompValCopy") OR ARRAYLEN(lastCompValCopy) LT compIndx)
						{
							lastCompValCopy[compIndx] = rate.set(
																currentRate,
																UOM,
																0,
																0,
																0,
																0,
																0,
																0,
																0,
																0,
																0,
                                								maxRate,
                                								prodID
																);
						}
					tmpCompVal[compIndx] = Duplicate(lastCompValCopy[compIndx]);
				</cfscript>
					<!---set comp id with no hyphens--->
					<cfset compIdNoHyphen = request.app_general_functions.replaceHyphen(arguments.stDataStructure.aComp[compIndx].compUUID) />

					<!---param uomId and rate--->
					<!--- <cfif StructKeyExists()></cfif> --->
					<!--- <cfif ArrayIsDefined(arguments.stDataStructure.aCompVal, counter) > --->
					<cfif ArrayLen(arguments.stDataStructure.aCompVal) GTE  counter>
						<!--- <cfif ArrayIsDefined(arguments.stDataStructure.aCompVal[counter], compIndx)> --->
						<cfif ArrayLen(arguments.stDataStructure.aCompVal[counter]) GTE compIndx>
							<!---if the max products to display is less than the amount of rebate products
							then default the rate and uom to what's in the data structure --->
							<cfif ArrayLen(arguments.stDataStructure.aProd) gt this.getMaxProducts()>
								<cfif not isDefined("form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#") or not isDefined("form.uom_#prodIdNoHyphen#_#compIdNoHyphen#")>
									<cfset stComponentRate = getDataStructureComponentRate(originalCompVal = originalCompVal, productID = prodID, compId = compIndx, defaultRates = lastCompValCopy[compIndx])>
									<cfparam name="form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#" default="#stComponentRate.rate#" />
									<cfparam name="form.uom_#prodIdNoHyphen#_#compIdNoHyphen#" default="#stComponentRate.uomId#" />

									<!--- Dev Note: drachala; D27521: HZPROD283  SARP PRG message . This value is greater than the template  START--->
										<!--- Get max rate from originalCompVal
											When products are deleted from templated, we are retainng max price when they are created. --->
			                       	<cfparam name="form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#_Tmplt" default="#stComponentRate.MaxRate#" />
									<!--- Dev Note: drachala; D27521: HZPROD283  SARP PRG message . This value is greater than the template  END--->
	     						</cfif>
							<cfelse>
								<cfparam name="form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#" default="0" />
								<cfparam name="form.uom_#prodIdNoHyphen#_#compIdNoHyphen#" default="1" />
							</cfif>
						<cfelse>
							<cfparam name="form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#" default="#lastCompValCopy[compIndx].rate#" />
							<cfparam name="form.uom_#prodIdNoHyphen#_#compIdNoHyphen#" default="#lastCompValCopy[compIndx].uomId#" />
						</cfif>
					<cfelse>
						<cfif ArrayLen(arguments.stDataStructure.aProd) gt this.getMaxProducts()>
							<cfif not isDefined("form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#") or not isDefined("form.uom_#prodIdNoHyphen#_#compIdNoHyphen#")>
								<cfset stComponentRate = getDataStructureComponentRate(originalCompVal = originalCompVal, productID = prodID, compId = compIndx, defaultRates = lastCompValCopy[compIndx])>
								<cfparam name="form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#" default="#stComponentRate.rate#" />
								<cfparam name="form.uom_#prodIdNoHyphen#_#compIdNoHyphen#" default="#stComponentRate.uomId#" />

								<!--- Dev Note: drachala; D27521: HZPROD283  SARP PRG message . This value is greater than the template  START--->
									<!--- Get max rate from originalCompVal
																	When products are deleted from templated, we are retainng max price when they are created. --->
							<cfparam name="form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#_Tmplt" default="#stComponentRate.MaxRate#" />
								<!--- Dev Note: drachala; D27521: HZPROD283  SARP PRG message . This value is greater than the template  END--->

							</cfif>
						<cfelse>
							<cfparam name="form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#" default="#lastCompValCopy[compIndx].rate#" />
							<cfparam name="form.uom_#prodIdNoHyphen#_#compIdNoHyphen#" default="#lastCompValCopy[compIndx].uomId#" />
						</cfif>
					</cfif>

					<!---set rate and uom in aCompVal--->
					<cfif NOT isNumeric(arguments.stDataStructure.aComp[compIndx].compNameID)>
						<cfset tmpCompNameID = 0>
					<cfelse>
						<cfset tmpCompNameID = arguments.stDataStructure.aComp[compIndx].compNameID>
					</cfif>
					<cfif NOT tmpUSDAComp.isUSDANOIComp(tmpCompNameID)>
						<cfset tmpCompVal[compIndx].rate = Evaluate("form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#") />

							<!--- Dev Note: drachala; D27521: HZPROD283  SARP PRG message . This value is greater than the template  START--->
								<!--- Get max rate from originalCompVal
																When products are deleted from templated, we are retainng max price when they are created. --->
						<cfif isDefined("form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#_Tmplt")>
							<cfset maxrate = form["comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#_Tmplt"] />
						</cfif>
							<!--- Dev Note: drachala; D27521: HZPROD283  SARP PRG message . This value is greater than the template  END--->
						<cfset tmpCompVal[compIndx].maxrate = maxrate />
					<cfelse>
						<cfset tmpCompVal[compIndx].rate = tmpUSDAComp.getUSDACompRate(prodID)>
						<cfset tmpCompVal[compIndx].maxrate = maxrate />
					</cfif>

					<cfset tmpCompVal[compIndx].uomId = Evaluate("form.uom_#prodIdNoHyphen#_#compIdNoHyphen#") />

				</cfloop>

				<!---now set to aCompVal key--->
				<cfset arguments.stDataStructure.aCompVal[counter] = tmpCompVal />

			</cfif>
<!--- 			<cfscript>

					//if we have components and products then build on the compRate object
					if (ArrayLen(arguments.stDataStructure.aCompVal) and isDefined("hasProducts"))
					{

						arguments.stDataStructure.aCompVal[counter] = lastCompValCopy;
					}

				//}

			</cfscript> --->

			<cfset counter = counter+1 />

		</cfloop>

		<cfset arrayMaxLen = ArrayLen(arguments.stDataStructure.aProd) />

		<cfloop index="x" from="#arrayMaxLen#" to="#counter#" step="-1">

			<cfset ArrayDeleteAt(arguments.stDataStructure.aProd, x) />

		</cfloop>

		<!---if we don't have any products then clear the components--->
		<cfif not ArrayLen(arguments.stDataStructure.aProd)>
			<cfset ArrayClear(arguments.stDataStructure.aComp) />
			<cfset ArrayClear(arguments.stDataStructure.aCompVal) />
		</cfif>

		<cfreturn arguments.stDataStructure />

	</cffunction>

	<cffunction name="addComp" output="true" returntype="struct">

		<cfargument name="stDataStructure" type="struct" required="true" default="" />
		<cfargument name="formScope" required="true" default="" />
		<cfargument name="contractMainID" required="true" default="" />
		<cfargument name="level3RateCanBeNull" type="numeric" required="false" default="0" />
		<cfargument name="EZTemplate" type="boolean" required="false" default="0" />
		<cfargument name="EZMaxRateOn" required="false" default="0">
		<cfargument name="EZABOVEMaxRateOn" required="false" default="0">

		<!--- D28783: Release 7 EZ Button Max Rate. On rebate page, when max rate is enabled, user should be able to enter beyond max rate --->
		<cfset arguments.EZABOVEMaxRateOn = 1 />
		<cfscript>

			//create instances of components
			comp = createObject("component","components.programs.rebates.RebateComponent");
			compRate = createObject("component","components.programs.rebates.RebateComponentRate");

			//if rate wasn't added then set to 0
			if (trim(arguments.formScope.rate) eq "")
			{
				arguments.formScope.rate = 0.000;
			}

			if (not isDefined("arguments.formScope.GL_Account_ID"))
			{
				arguments.formScope.GL_Account_ID = 0;
			}

			if (not isDefined("arguments.formScope.Vendor_Master_ID"))
			{
				arguments.formScope.Vendor_Master_ID = 0;
			}

			if (not comp.checkExists(arguments.stDataStructure.aComp,arguments.formScope.compUUID))
			{
				ArrayAppend(arguments.stDataStructure.aComp, comp.set(	'',
																		arguments.formScope.compNameId,
																		arguments.contractMainID,
																		arguments.formScope.compUUID,
																		arguments.formScope.Component_Paid_To,
																		arguments.formScope.GL_Account_ID,
																		arguments.formScope.Vendor_Master_ID,
																		arguments.formScope.PaymentCycle,
																		arguments.formScope.Claim_Mechanics,
																		arguments.formScope.Basis_Code,
																		arguments.formScope.Treatment_Code,
																		arguments.formScope.VendorSelection,
																		"0",
																		arguments.formScope.Payee_Selection
																		)
																	);

				UOM = arguments.formScope.UOM;
        		maxRate = 0;
				//if the aProd array holds data then append for each element, otherwise add by assignment
				if (ArrayLen(arguments.stDataStructure.aProd))
				{
					//if the aCompVal array holds data then we can append to it, otherwise we have to add to the array by assignment
					if (ArrayLen(arguments.stDataStructure.aCompVal))
					{
						for (i=1; i lte ArrayLen(arguments.stDataStructure.aProd); i=i+1)
						{

              				// Added for 21553
			                currentRate = arguments.formScope.rate;
			                UOM = arguments.formScope.UOM;
			                maxRate = 0;

                			if ((arguments.stDataStructure.aProd[i].EZ_Contract_Id NEQ 0) AND (arguments.stDataStructure.aProd[i].EZ_Contract_Id NEQ "") AND arguments.EZTemplate EQ 0)
							{ // addComp
							  ezRate = getRebateProductComponentRate(
							            arguments.stDataStructure.aProd[i].EZ_Contract_Id,
							            arguments.stDataStructure.aProd[i].masterItemID,
							            arguments.formScope.compNameId,
							            arguments.formScope.Component_Paid_To);

							  UOM = ezRate.UOM;
							  // D28783: Release 7 EZ Button Max Rate. We no longer need to store the max rate on the program, always use the max rate from the latest template
							  //maxRate = ezRate.rate;
							  /*Dev Note: Drachala; D27506 : EZ Button, max rate - allow user to enter default rate and mass apply rate START*/
							  if(!arguments.EZMaxRateOn){
								currentRate =    ezRate.Rate;
							  }

							  else{
							  // is Ezbutton AND Max Rate AND  Template settings Enter Beyond Max Rate --- YES
							  	if(EZABOVEMaxRateOn)
							  	{
							  	 	  currentRate = arguments.formScope.rate;
							  	 }
							  	 else if(currentRate GT maxRate)
							  	 {
							  	 	currentRate = " ";
							  	 }
							  	 else
							  	 {
							  	 	currentRate = arguments.formScope.rate;
							  	 }

							  }

							}

							if(arguments.level3RateCanBeNull AND arguments.stDataStructure.aProd[i].pricingLevel EQ 3)
							{
								currentRate = 0;
							}

							if( NOT comp.isUSDANOIComp(arguments.formScope.compNameId)) {
								ArrayAppend(arguments.stDataStructure.aCompVal[i],
										compRate.set(
											rate=currentRate,
                      						UOMID=UOM,
											contractProdID=arguments.stDataStructure.aProd[i].contractProdID,
                      						maxRate=maxRate,
                      						prodID=arguments.stDataStructure.aProd[i].masterItemID
											));
							}
							else {
								ArrayAppend(arguments.stDataStructure.aCompVal[i],
										compRate.set(
											rate=comp.getUSDACompRate(arguments.stDataStructure.aProd[i].masterItemID),
											uomID=arguments.formScope.UOM,
											compID='',
											contractProdID=arguments.stDataStructure.aProd[i].contractProdID,
											prodID=arguments.stDataStructure.aProd[i].masterItemID
											));
							}
						}
					}
					else
					{


						for (i=1; i lte ArrayLen(arguments.stDataStructure.aProd); i=i+1)
						{
            				// Added for 21553

							currentRate = arguments.formScope.rate;
							UOM = arguments.formScope.UOM;
							maxRate = 0;

							if ((arguments.stDataStructure.aProd[i].EZ_Contract_Id NEQ 0) AND (arguments.stDataStructure.aProd[i].EZ_Contract_Id NEQ "") AND arguments.EZTemplate EQ 0)
							{ // addComp
							  ezRate = getRebateProductComponentRate(
							            arguments.stDataStructure.aProd[i].EZ_Contract_Id,
							            arguments.stDataStructure.aProd[i].masterItemID,
							            arguments.formScope.compNameId,
							            arguments.formScope.Component_Paid_To);
							            /*UOM = ezRate.UOM ;D45434	 :: When EZ button is on UOM selected on default rate is overridden by UOM from EZ Button*/
							  			maxRate = ezRate.rate;
						       /*Dev Note: Drachala; D27506 : EZ Button, max rate - allow user to enter default rate and mass apply rate START*/
							  if(!arguments.EZMaxRateOn){
								currentRate =    ezRate.Rate;
							  }

							  else{
							  // is Ezbutton AND Max Rate AND  Template settings Enter Beyond Max Rate --- YES
							  	if(EZABOVEMaxRateOn)
							  	{
							  	 	  currentRate = arguments.formScope.rate;
							  	 }
							  	 else if(currentRate GT maxRate)
							  	 {
							  	 	currentRate = " ";
							  	 }
							  	 else
							  	 {
							  	 	currentRate = arguments.formScope.rate;
							  	 }

							  }

							}


							if(arguments.level3RateCanBeNull AND arguments.stDataStructure.aProd[i].pricingLevel EQ 3)
							{
								currentRate = 0;writeOutput(currentRate);
							}
							tmpArray = ArrayNew(1);
							if( NOT comp.isUSDANOIComp(arguments.formScope.compNameId)) {
								// tmpArray[1] = compRate.set(currentRate,arguments.formScope.UOM,'',arguments.contractMainID);
                				tmpArray[1] = compRate.set(
                      				rate=currentRate,
                      				UOMID=UOM,
									contractProdID=arguments.stDataStructure.aProd[i].contractProdID,
                      				maxRate=maxRate,
                      				prodID=arguments.stDataStructure.aProd[i].masterItemID
                      				);
							}
							else {
								tmpArray[1] = compRate.set(
									rate=comp.getUSDACompRate(arguments.stDataStructure.aProd[i].masterItemID),
									uomID=arguments.formScope.UOM,
									compID='',
									contractProdID=arguments.stDataStructure.aProd[i].contractProdID,
									prodID=arguments.stDataStructure.aProd[i].masterItemID
									);
                					//(comp.getUSDACompRate(arguments.stDataStructure.aProd[i].masterItemID),arguments.formScope.UOM,'',arguments.contractMainID)
							}
							arguments.stDataStructure.aCompVal[i] = tmpArray;
						}
					}
				}
				else
				{
					if( NOT comp.isUSDANOIComp(arguments.formScope.compNameId)) {
						//arguments.stDataStructure.aCompVal[ArrayLen(arguments.stDataStructure.aComp)] = compRate.set(arguments.formScope.rate,arguments.formScope.UOM,'',arguments.contractMainID);
            			arguments.stDataStructure.aCompVal[ArrayLen(arguments.stDataStructure.aComp)] = compRate.set(
            					currentRate,
                        		UOM,
								'',
								arguments.stDataStructure.aProd[i].contractProdID,
	                      		'','','','','',0,
	                      		maxRate,
	                      		arguments.stDataStructure.aProd[i].masterItemID
	                      		);
					}
					else {
						arguments.stDataStructure.aCompVal[ArrayLen(arguments.stDataStructure.aComp)] = compRate.set(
							comp.getUSDACompRate(arguments.stDataStructure.aProd[i].masterItemID),
							arguments.formScope.UOM,
							'',
							arguments.contractMainID
							);
					}
					//arguments.stDataStructure.aCompVal[ArrayLen(arguments.stDataStructure.aComp)] = compRate.set(arguments.formScope.rate,arguments.formScope.UOM,'',arguments.contractMainID);
				}
			}
		</cfscript>

		<cfset UpdStatus = UpdateGroupStatus('#arguments.contractMainID#')>

		<cfreturn arguments.stDataStructure/>

	</cffunction>

	<cffunction name="remProd" output="false" returntype="struct">

		<cfargument name="stDataStructure" type="struct" required="true" default="" />
		<cfargument name="lProdList" required="true" default="" />


		<!---take a snap shot of the first element of compVal array to use as a placeholder if we remove all elements.
		Check to see if it contains any elements first--->
		<cfif ArrayLen(arguments.stDataStructure.aCompVal)>

			<cfset tmpArray =  ArrayNew(1) />
			<cfset tmpArray = Duplicate(arguments.stDataStructure.aCompVal[1]) />

		</cfif>

		<cfset initialiseGroupLevel() />

		<cfloop index="arrayIndx" from="#ArrayLen(arguments.stDataStructure.aProd)#" to="1" step="-1">

			<cfscript>

				if (not ListFindNoCase(arguments.lProdList, arguments.stDataStructure.aProd[arrayIndx].masterItemID))
				{

					ArrayDeleteAt(arguments.stDataStructure.aProd, arrayIndx);
					//check to see if aCompVal is empty
					if (ArrayLen(arguments.stDataStructure.aCompVal))
					{
						ArrayDeleteAt(arguments.stDataStructure.aCompVal, arrayIndx);
					}
				}
				else
				{	
					addToGroupLevel(arguments.stDataStructure.aProd[arrayIndx].productGroupLevelTypeId, arguments.stDataStructure.aProd[arrayIndx].pricingLevel);
				}

			</cfscript>

		</cfloop>


		<!---if we remove all of the products and we have elements in the component array then we have to populate the component value array--->
<!--- 		<cfif not ArrayLen(arguments.stDataStructure.aProd) and ArrayLen(arguments.stDataStructure.aComp)>
			<cfset arguments.stDataStructure.aCompVal = tmpArray />
		</cfif> --->

		<!---TSF: Modification--->
		<!---if we don't have any products then we are going to clear the components--->
		<cfif not ArrayLen(arguments.stDataStructure.aProd)>
			<cfset ArrayClear(arguments.stDataStructure.aComp) />
			<cfset ArrayClear(arguments.stDataStructure.aCompVal) />
		</cfif>

		<cfreturn arguments.stDataStructure/>

	</cffunction>

	<cffunction name="remComp" output="false" returntype="struct">

		<cfargument name="stDataStructure" type="struct" required="true" default="" />
		<cfargument name="lRemCompList" required="true" default="" />

		<cfif ArrayLen(arguments.stDataStructure.aProd) GT 0>
			<cfset UpdStatus = UpdateGroupStatus('#arguments.stDataStructure.aProd[1].ProgramID#')>
		</cfif>

		<cfloop index="indx" from="#ListLen(arguments.lRemCompList)#" to="1" step="-1">

			<cfscript>

				ArrayDeleteAt(arguments.stDataStructure.aComp, ListGetAt(arguments.lRemCompList, indx));

				//if our prod array is empty then the comp val array position is different so we have to catch for that
				if (ArrayLen(arguments.stDataStructure.aProd))
				{
					//if the component struct key does not hold any arrays then we have to clear out all arrays in the compVal array
					if (not arrayLen(arguments.stDataStructure.aComp))
					{
						ArrayClear(arguments.stDataStructure.aCompVal);
					}

					else
					{
						for (i = 1; i lte ArrayLen(arguments.stDataStructure.aCompVal); i=i+1)
						{
							ArrayDeleteAt(arguments.stDataStructure.aCompVal[i], ListGetAt(arguments.lRemCompList, indx));
						}
					}
				}
				else if (ArrayLen(arguments.stDataStructure.aCompVal))
				{
					ArrayDeleteAt(arguments.stDataStructure.aCompVal, ListGetAt(arguments.lRemCompList, indx));
				}

			</cfscript>

		</cfloop>

		<cfreturn arguments.stDataStructure/>

	</cffunction>

	<cffunction name="applyVol" output="false" returntype="struct">

		<cfargument name="stDataStructure" type="struct" required="true" default="" />
		<cfargument name="lProdVol" required="true" default="" />
		<cfargument name="volume" required="true" default="" />


		<cfloop index="indx" from="1" to="#ListLen(arguments.lProdVol)#">

			<cfloop index="i" from="1" to="#ArrayLen(arguments.stDataStructure.aProd)#">

				<cfif not CompareNoCase(ListGetAt(arguments.lProdVol,indx), arguments.stDataStructure.aProd[i].masterItemId)>

					<cfscript>
						arguments.stDataStructure.aProd[i].volume = arguments.volume;
					</cfscript>

				</cfif>

			</cfloop>

		</cfloop>

		<cfreturn arguments.stDataStructure />

	</cffunction>

	<cffunction name="applyVolComp" output="false" returntype="struct">

		<cfargument name="stDataStructure" type="struct" required="false" default="" />
		<cfargument name="lProd" required="false" default="" />
		<cfargument name="lComp" required="false" default="" />
		<cfargument name="rate" required="false" default="" />
		<cfargument name="uom" required="false" default="" />
		<cfargument name="apply_basis_code_quantity" required="false" default="" />
		<cfargument name="apply_basis_code_quantity_uom" required="false" default="" />
		<cfargument name="apply_basis_code_free_goods" required="false" default="" />
		<cfargument name="Display_Basis_Treatment_Code" required="false" default="0" />
		<cfargument name="apply_effective_margin_Percent" required="false" default="" />
		<cfargument name="action" required="false" default="" />
		<cfargument name="EZABOVEMaxRateOn" required="false" default="0">
		<cfargument name="EZbutton" required="false" default="0">
		<cfargument name="EZTemplate" required="false" default="0">		
		<cfargument name="fromMassApply" required="false" default="0"><!--- D38846 ::  Recapture changes START--->

		<!--- D28783: Release 7 EZ Button Max Rate. On rebate page, when max rate is enabled, user should be able to enter beyond max rate --->
		<!--- <cfset arguments.EZABOVEMaxRateOn = 1 />--->

		<cfset BasisCodeManager = CreateObject("component","components.Operating_Group.BasisCodeManager").init() />
		<cfloop index="i" from="1" to="#ListLen(arguments.lProd)#">

			<cfloop index="indx" from="1" to="#ArrayLen(arguments.stDataStructure.aProd)#">
				<cfset currProd = arguments.stDataStructure.aProd[indx] />
				<cfset MasterItemID = structfind(currProd, "MasterItemID")>
				<cfset temp = "">

				<cfif MasterItemID IS ListGetAt(arguments.lProd,i)>
					<cfset temp = 1>
				</cfif>

				<cfif Len(temp)>



					<cfloop index="n" from="1" to="#ListLen(arguments.lComp)#">
						<!--- <cfset ar_mass_Check = arraynew(1)>D38846 ::  Recapture changes --->
						<cfset componentPosition = ListGetAt(arguments.lComp,n) />

						<cfset basisCodeType = 0 />
						<cfif arguments.Display_Basis_Treatment_Code EQ 1>
							<cfif BasisCodeManager.getBasicCodeType(arguments.stDataStructure.aComp[componentPosition].BasisCode) EQ "Y">
								<cfset basisCodeType = 1 />
							</cfif>
						</cfif>
						<!--- D38846 ::  Recapture changes START
							<cfif n GT 1>
								<cfloop from="1" to="#arguments.stDataStructure.aComp[n].alternate_recapture_rate#" index="ARC">
								<cfset ARC = ARC + #arguments.stDataStructure.aComp[n-1].alternate_recapture_rate#>
								 <cfset arrayappend(ar_mass_Check, ar_massApply_check[ARC])>
								 </cfloop>
							<cfelse>
								<cfloop from="1" to="#arguments.stDataStructure.aComp[n].alternate_recapture_rate#" index="ARC">
								 <cfset arrayappend(ar_mass_Check, ar_massApply_check[ARC])>
								 </cfloop>
							</cfif>
						D38846 ::  Recapture changes END--->
						<cfscript>
							//this.dmp(arguments);
							//don't change the rate and uom if the rebate component type is price protection (rebate_type = 2)
							if(arguments.stDataStructure.aComp[componentPosition].rebate_type neq 2)
							{
								if(basisCodeType eq 0)
								{

									if (Len(trim(arguments.rate)))
									{		/* Since the restriction on rates is on the program based on template rates, allow any rate to be set
											by the user on the template. This code was added so that "multi-assign rate" can work from the template.
											*/									
											if(EZbutton && EZTemplate eq 1){
												arguments.stDataStructure.aCompVal[indx][componentPosition].rate = arguments.rate;
											}
											 /*Dev Note: Drachala; D27506 : EZ Button, max rate - allow user to enter default rate and mass apply rate START*/
											else if ((EZbutton) && (EZABOVEMaxRateOn))
								  			 {	    //removed LT check since EZABOVEMaxRateOn says user can enter rate above maxrate
     												//if(arguments.rate LT arguments.stDataStructure.aCompVal[indx][componentPosition].maxRate)
													//{
														arguments.stDataStructure.aCompVal[indx][componentPosition].rate = arguments.rate;
													//}
							  				 }
							  				 else if (EZbutton)
							  				 {
    						  				 	    if(arguments.rate LT arguments.stDataStructure.aCompVal[indx][componentPosition].maxRate)
													{
														arguments.stDataStructure.aCompVal[indx][componentPosition].rate = arguments.rate;
													}
							  				 }
							  				 else //if getRestrictProductUom() we need to convert Rate based on UOM :: D27185
							  				 {
							  				 	  if(appSettings.getRestrictProductUom() == 1){
							  				 	  	 //only convert cs -> lb or lb -> cs.  let % fall through.
							  				 	  	if(arguments.uom == 1 && currProd.productInventoryUomId == 2){
							  				 			arguments.stDataStructure.aCompVal[indx][componentPosition].rate = arguments.rate/currProd.netWeight;
							  				 		}
							  				 		else if(arguments.uom == 2 && currProd.productInventoryUomId == 1){
							  				 			arguments.stDataStructure.aCompVal[indx][componentPosition].rate = arguments.rate * currProd.netWeight;
							  				 		}
							  				 		else{
							  				 			arguments.stDataStructure.aCompVal[indx][componentPosition].rate = arguments.rate;
							  				 		}
							  				 	  }
							  				 	  else{//no appsetting
							  				 	  	arguments.stDataStructure.aCompVal[indx][componentPosition].rate = arguments.rate;
							  				 	  }
							  				 }
			/*Dev Note: Drachala; D27506 : EZ Button, max rate - allow user to enter default rate and mass apply rate END*/

									}

									/*if (Len(trim(arguments.rate)))
										arguments.stDataStructure.aCompVal[indx][componentPosition].rate = arguments.rate;*/

									if (trim(arguments.uom)){
										if(appSettings.getRestrictProductUom() == 1 && (arguments.uom == 1 || arguments.uom == 2)){
											arguments.stDataStructure.aCompVal[indx][componentPosition].uomId = currProd.productInventoryUomId;
										}
										else{
											arguments.stDataStructure.aCompVal[indx][componentPosition].uomId = arguments.uom;
										}

									}

									/*
									for scan components if the uom selected by the user is "each", we store the rate entered by the user in the scan rate field
									and will store the rate converted to product UOM in the regular rate fields so that we do not have to change the rest of the application for now.
									once we have logic to handle uom="each" in other parts of the app we can remove the following conversion.

									if rebate type = Variable/Fixed Combo and uom=EA
									*/
									_rate = arguments.stDataStructure.aCompVal[indx][componentPosition].rate;
									variables.uom = arguments.stDataStructure.aCompVal[indx][componentPosition].uomId;
									scanRate = _rate;
									scanUom = variables.uom;
									if(arguments.stDataStructure.aComp[n].rebate_type == 4 && variables.uom == 5)
									{
										variables.uom = 1;
										if(arguments.stDataStructure.aProd[i].productInventoryUOM == "LB")
										{
											variables.uom = 2;
										}

										_rate = _rate * arguments.stDataStructure.aProd[i].EAConversion;
									}

									if (Len(trim(arguments.rate)) and trim(variables.uom) and action == "updSave")
									{ //write this to the DB and be done
										arUpdSave[1] = _rate;
										arUpdSave[2] = variables.uom;
										arUpdSave[3] = arguments.stDataStructure.aCompVal[indx][componentPosition].Program_Rebates_Component_Data_ID; //do not need form field since this is hidden we know it is in struct
										//arUpdSave[4] = "";
										//arUpdSave[5] = "";
										if(arguments.stDataStructure.aComp[n].rebate_type == 4)
										{
											arUpdSave[6] = arguments.stDataStructure.aCompVal[indx][componentPosition].scanVolume;
											arUpdSave[8] = scanRate;
											arUpdSave[9] = scanUom;
										}
										else
										{
											arUpdSave[6] = "";
											arUpdSave[8] = "";
											arUpdSave[9] = "";
										}
										arUpdSave[7] = arguments.stDataStructure.aCompVal[indx][componentPosition].ruleId;
										arUpdSave[10] = arguments.stDataStructure.aProd[i].Competitor_Price;
										arUpdSave[11] = arguments.stDataStructure.aProd[i].Competitor_Name_ID;
										arUpdSave[12] = arguments.stDataStructure.aProd[i].Competitor_Time_Frame;
										arUpdSave[13] = '';

										arUpdSave[14] = arguments.stDataStructure.aComp[n].alternate_recapture_rate;
										arUpdSave[15] = arguments.stDataStructure.aCompVal[i][n].contractprodid;
										arUpdSave[16] = arraynew(1);
										arUpdSave[17] = arraynew(1);
										arUpdSave[18] = arguments.stDataStructure.aComp[n].compnameid;
										//D38846 ::  Recapture changes START
										arUpdSave[19] = arguments.fromMassApply;
										//D38846 ::  Recapture changes END
										this.saveProdRate(arUpdSave, 1);
										/*this.updRebateProductData(	Program_ID,
												qUpdRebateProduct.Program_Rebates_Product_Data_ID,
												Competitor_Price,
												Competitor_Name_ID,
												Competitor_Time_Frame);*/
									}
								}
								if (Len(trim(arguments.apply_basis_code_quantity)))
									arguments.stDataStructure.aCompVal[indx][componentPosition].basisCodeQuantity = arguments.apply_basis_code_quantity;
								if (Len(trim(arguments.apply_basis_code_quantity_uom)))
									arguments.stDataStructure.aCompVal[indx][componentPosition].basisCodeQuantityUom = arguments.apply_basis_code_quantity_uom;
								if (Len(trim(arguments.apply_basis_code_free_goods)))
									arguments.stDataStructure.aCompVal[indx][componentPosition].basisCodeFreeGoods = arguments.apply_basis_code_free_goods;
								if (Len(trim(arguments.apply_effective_margin_Percent)) and IsNumeric(arguments.apply_effective_margin_Percent) and arguments.stDataStructure.aComp[componentPosition].EffectiveMarginFlag EQ 1)
									arguments.stDataStructure.aCompVal[indx][componentPosition].effectMarginPercent = arguments.apply_effective_margin_Percent;
							}

						</cfscript>

					</cfloop>

				</cfif>

			</cfloop>

		</cfloop>

		<cfreturn arguments.stDataStructure />

	</cffunction>

	<!--- get inventory UOM for a Prod--->
	<!---	<cffunction name="get_Attribute_Type" output="false" returntype="string">
   		<cfargument name="BSA_Foodservice_Items_Master_ID" type="string" required="true" default="">
			<cfquery name="qry_get_Attribute_Type" datasource="#application.datasource#">
			SELECT	TOP 1 A.Product_Group_Attribute_Master_ID_Field
			FROM	Product_Group_Attribute A INNER JOIN contract_products B
			ON A.Product_Group_Level_ID = B.Product_Group_Level_ID
			WHERE B.BSA_Foodservice_Items_Master_ID = '#arguments.BSA_Foodservice_Items_Master_ID#'
			AND B.Deleted = 0
			</cfquery>
		<cfreturn qry_get_Attribute_Type.Product_Group_Attribute_Master_ID_Field />
   	</cffunction>--->

	<cffunction name="calculate" output="false" returntype="array">

		<cfargument name="aProd" type="array" required="false" default="this.stRebate.aProd" />
		<cfargument name="aComp" type="array" required="false" default="this.stRebate.aComp" />
		<cfargument name="aCompVal" type="array" required="false" default="this.stRebate.aCompVal" />

		<cfset aReturnRebate = ArrayNew(1) />

		<!---if we have components and products then we can run calculations--->
		<cfif ArrayLen(arguments.aProd) and ArrayLen(arguments.aComp)>

			<cfscript>

				//start loop through the product array first
				for (i = 1; i lte ArrayLen(arguments.aProd); i = i+1)
				{
					rebateVal = 0;

					//then loop through the component array
					for (n = 1; n lte ArrayLen(arguments.aComp); n = n+1)
					{

						uom = trim(arguments.aCompVal[i][n].uomID);
						tmpVar = 0;
						switch (uom)
						{
							case "1":
							{
								tmpVar = arguments.aCompVal[i][n].rate / arguments.aProd[i].netWeight;
								break;
							}

							case "2":
							{

								tmpVar = arguments.aCompVal[i][n].rate;
								break;
							}

							case "3":
							{
								tmpVar = (arguments.aCompVal[i][n].rate * arguments.aProd[i].fobPrice) / 100;
								break;
							}

						}

						rebateVal = rebateVal + tmpVar;

					}

					tmpStruct = StructNew();
					tmpStruct.rebateVal = rebateVal;
					tmpStruct.masterItemId = arguments.aProd[i].masterItemId;
					aReturnRebate[i] = tmpStruct;
				}

			</cfscript>

		</cfif>

		<cfreturn aReturnRebate />

	</cffunction>

	<cffunction name="setGroups" output="false">

		<cfargument name="stDataStructure" type="struct" required="true" default="" />
		<cfargument name="lProdList" required="true" default="" />
		<cfargument name="contractMainID" required="true" default="" />
		<cfargument name="groupObj" required="false" default="" />
		<cfargument name="level3" required="false" default="" />
		<cfargument name="EZTemplate" required="false" default="" />
		<cfargument name="EZ_Contract_ID" required="false" default="0">
		<cfargument name="EZMaxRateOn" required="false" default="0">

		<cfset arguments.stDataStructure = this.addProd(arguments.stDataStructure,
														arguments.lProdList,
														arguments.contractMainID,
														1,
														arguments.level3,
														0,
														arguments.EZTemplate,
														arguments.EZ_Contract_ID,
														arguments.EZMaxRateOn) />

		<!------ Get pricing level descriptions ----->
		<cfset qGetPricingLevel = this.GroupDataManager.getPricingLevel() />
		<cfset arPricingLevel = ListToArray(ValueList(qGetPricingLevel.Pricing_Level_Desc, ","), ",") />
		<cfset arPricingLevelLen = ArrayLen(arPricingLevel) />

		<cfset initialiseGroupLevel() />

		<!---loop over the product array and set the values from the Group object to the values in the product array--->
		<cfloop index="indx" from="1" to="#ArrayLen(arguments.stDataStructure.aProd)#">

			<!---if we find this item master id in the Group objects product list then let's get the values from the Group object--->
			<cfif ListFindNoCase(arguments.groupObj.getLProductIds(), arguments.stDataStructure.aProd[indx].masterItemId)>

				<!---set temp group object for this array element--->
				<cfset tmpGroupObj = arguments.groupObj.getGroups() />

				<!---loop over the group objects and find the matching group--->
				<cfloop index="groupIndx" from="1" to="#ArrayLen(tmpGroupObj)#">

					<!---if they are equal then set values--->
					<cfif tmpGroupObj[groupIndx].getTempItemMasterId() eq arguments.stDataStructure.aProd[indx].masterItemId>

						<cfset arguments.stDataStructure.aProd[indx].description = tmpGroupObj[groupIndx].getGroupLevelDesc() />
						<!--- Dev Note: KAL; New template settings for Group UOM selections --->
						<cfif tmpGroupObj[groupIndx].getUom() EQ 1>
							<cfset arguments.stDataStructure.aProd[indx].productInventoryUOM	=	"CS" />
						<cfelseif tmpGroupObj[groupIndx].getUom() EQ 2>
							<cfset arguments.stDataStructure.aProd[indx].productInventoryUOM	=	"LB" />
						</cfif>
						<cfset arguments.stDataStructure.aProd[indx].pricingLevel = tmpGroupObj[groupIndx].getPricingLevel() />
						<cfset pricingLevelDesc = "" />
						<cfif arguments.stDataStructure.aProd[indx].pricingLevel GT 0 AND arguments.stDataStructure.aProd[indx].pricingLevel LTE arPricingLevelLen>
							<cfset pricingLevelDesc = arPricingLevel[arguments.stDataStructure.aProd[indx].pricingLevel] />
						</cfif>
						<cfset arguments.stDataStructure.aProd[indx].pricingLevelDesc = pricingLevelDesc />
						<cfset arguments.stDataStructure.aProd[indx].productGroupID = tmpGroupObj[groupIndx].getProductGroupId() />
						<cfset arguments.stDataStructure.aProd[indx].productGroupLevel = tmpGroupObj[groupIndx].getGroupLevelId() />
						<cfset arguments.stDataStructure.aProd[indx].isGroup = 1 />
						<cfset arguments.stDataStructure.aProd[indx].productGroupLevelTypeId = tmpGroupObj[groupIndx].getProductGroupLevelType() />
						<cfset arguments.stDataStructure.aProd[indx].upc = "Group Product" />
						<cfset arguments.stDataStructure.aProd[indx].productGroupForThisProduct = "" />
						<cfif arguments.stDataStructure.aProd[indx].productGroupLevelTypeId eq 2>
							<!---get the product hierarchy id if it's a product hierarchy--->
							<cfquery name="qGetHierarchyId" datasource="#application.datasource#">
								SELECT 	Product_Hierarchy
								FROM 	Product_Hierarchy
								WHERE 	Product_Hierarchy_ID = '#trim(arguments.stDataStructure.aProd[indx].productGroupID)#'
							</cfquery>
							<cfset arguments.stDataStructure.aProd[indx].item = qGetHierarchyId.Product_Hierarchy />
						</cfif>

					</cfif>

				</cfloop>

			</cfif>
			<cfif arguments.stDataStructure.aProd[indx].productGroupLevel EQ "">
				<cfset arguments.stDataStructure.aProd[indx].productGroupLevel = "0">
			</cfif>
			<cfset addToGroupLevel(groupLevelId = arguments.stDataStructure.aProd[indx].productGroupLevel, pricingLevelId = arguments.stDataStructure.aProd[indx].pricingLevel) />

		</cfloop>

		<cfreturn arguments.stDataStructure />

	</cffunction>
	<!--- get the Attribute (q_brand_id, or Type_code_id etc) --->
	<cffunction name="get_Attribute_Type" output="false" returntype="string">
   		<cfargument name="BSA_Foodservice_Items_Master_ID" type="string" required="true" default="">
			<cfquery name="qry_get_Attribute_Type" datasource="#application.datasource#">
			SELECT	TOP 1 A.Product_Group_Attribute_Master_ID_Field
			FROM	Product_Group_Attribute A INNER JOIN contract_products B
			ON A.Product_Group_Level_ID = B.Product_Group_Level_ID
			WHERE B.BSA_Foodservice_Items_Master_ID = '#arguments.BSA_Foodservice_Items_Master_ID#'
			AND B.Deleted = 0
			</cfquery>
		<cfreturn qry_get_Attribute_Type.Product_Group_Attribute_Master_ID_Field />
   	</cffunction>
	<!--- get the value of the Attribute (q_brand_id, or Type_code_id etc) --->
	<cffunction name="get_Attribute_Value" output="false" returntype="string">
   		<cfargument name="FieldName" type="string" required="true" default="">
		<cfargument name="BSA_Foodservice_Items_Master_ID" type="string" required="true" default="">

		<cfif arguments.FieldName EQ "PG_Product_Category_ID">
			<cfquery name="qry_get_Attribute_Value" datasource="#application.datasource#">
      SELECT #arguments.FieldName#
      FROM  PG_Product_Members WHERE
			BSA_Foodservice_Items_Master_ID  = '#arguments.BSA_Foodservice_Items_Master_ID#'
			</cfquery>
		<cfelse>
			<cfquery name="qry_get_Attribute_Value" datasource="#application.datasource#">
			SELECT	#arguments.FieldName#
			FROM	BSA_Foodservice_Items_Master
			WHERE BSA_Foodservice_Items_Master_ID = '#arguments.BSA_Foodservice_Items_Master_ID#'
			</cfquery>
		</cfif>
			<cfset FieldValue = evaluate('qry_get_Attribute_Value.#arguments.FieldName#')>
		<cfreturn FieldValue />
   	</cffunction>
	<!--- Dev Note: CPM 8605 - Altered the sort to include displaygroupname (for sorting by typecode) --->
	<cffunction name="sort" output="true" returntype="struct">
		<cfargument name="stDataStructure" type="struct" required="false" default="" />
		<cfargument name="sortBy" type="string" required="false" default="" />
		<cfargument name="sortOrder" type="string" required="false" default="" />

		<cfset Groups_Exist = 0>
		<cfset MASTER_ITEM_ID ="">
		<cfset Field_Name = "">
		<!--- Loop through the product list and Check whether Groups Exist. If yes, then grab the Item ID and the group attribute
			  type (q_brand_id, or Type_code_id etc) --->
		<cfloop from="1" to="#ArrayLen(arguments.stDataStructure.aProd)#" index="i">
			<cfif arguments.stDataStructure.aProd[i].IsGroup eq 1>
					<cfset Groups_Exist = 1>
					<cfset MASTER_ITEM_ID = arguments.stDataStructure.aProd[i].MASTERITEMID>
					<cfset Field_Name = get_Attribute_Type('#MASTER_ITEM_ID#')>
					<cfbreak>
			</cfif>
		</cfloop>
		
		<cfif (isDefined("FORM.ProductsGroupLevels") AND FORM.ProductsGroupLevels NEQ "")>
			<cfset FORM.ProductsGroupLevels = Replace(FORM.ProductsGroupLevels,"|,", "|")>
			<cfset Groups_Exist = 1>
			<cfloop from="1" to="#ArrayLen(arguments.stDataStructure.aProd)#" index="i">
				<cfloop list="#FORM.ProductsGroupLevels#" index="k1" delimiters="|" >	
					<cfset strToken = Trim(k1) />
					<cfif strToken NEQ "">
						<cfset strRow = ListToArray(strToken)>
						<cfset varGroupProductID = strRow[1] />
						<cfset varGroupLevelID =  strRow[2] />
						<cfset varGroupLevelType = strRow[3] />
						<!--- <cfset varGroupProductID = Left(strToken,36)>
						<cfset varGroupLevelType = right(strToken,(len(strToken)-37)) /> --->
						<!--- Check to see if the masterItemID within the products is the same within the Group also --->
						<cfif arguments.stDataStructure.aProd[i].MasterItemID EQ varGroupProductID>
							<cfset arguments.stDataStructure.aProd[i].ProductGroupID = varGroupProductID />
							<cfset arguments.stDataStructure.aProd[i].isGroup = "1" />
							<cfset arguments.stDataStructure.aProd[i].ProductGroupLevel = varGroupLevelType />
							<cfset arguments.stDataStructure.aProd[i].PricingLevel = "1" />
							<cfset arguments.stDataStructure.aProd[i].PricingLevelDesc = "Level 1" />
						</cfif>
					</cfif>		
				</cfloop>
			</cfloop>
		</cfif>


			<cftry>
			<cfquery datasource="#application.datasource#">
			if object_id('tempdb..##qTmp') is not null
			drop table ##qTmp
			</cfquery>
			<cfset Table_Created = 0>
			<!--- If the temp table does not exist, create either the one with a group attribute or one without (depending on whether groups exist or not)  --->
				<cfif Table_Created eq 0>
					<cfif Groups_Exist  eq 1 AND Field_Name neq "">
						<cfquery datasource="#application.datasource#">
						CREATE TABLE ##qTmp (
											oldArrayIndx  Int  Identity (1,1) PRIMARY KEY CLUSTERED,
											item varchar(50),
											upc varchar(50),
											description varchar(50),
											pricingLevel Int,
											displaygroupname varchar(50),
											#Field_Name# NVARCHAR(50),
											masterItemID varchar(37),
											productGroupLevel INT,
											productGroupID VARCHAR(37),
											isGroup BIT,
											EZButton_On_Default BIT,
                      						EZ_Contract_Id INT,
											Base_Sales_CS NVARCHAR(50), <!--- D30357:Today's Price Wrong on Revision History END--->
											groupNumber varchar(100)
											)
						</cfquery>
					<cfelse>
							<!--- If there are no groups --->
							<cfquery datasource="#application.datasource#">
							CREATE TABLE ##qTmp (
												oldArrayIndx  Int  Identity (1,1) PRIMARY KEY CLUSTERED,
												item varchar(50),
												upc varchar(50),
												description varchar(50),
												pricingLevel Int,
												displaygroupname varchar(50),
												masterItemID varchar(37),
												productGroupLevel INT,
												productGroupID VARCHAR(37),
												isGroup BIT,
												EZButton_On_Default BIT,
                        						EZ_Contract_Id INT,
												Base_Sales_CS NVARCHAR(50), <!--- D30357:Today's Price Wrong on Revision History END--->
												groupNumber varchar(100)
												)
							</cfquery>
					</cfif>
				</cfif>
					<cfset Table_Created = 1>
				<cfset crlf = chr(13) & chr(10)>
			<!--- Get the group Attribute's value --->
			<cfparam name="Field_Value" default="">
			<!--- The MasterItemID of the level 1 is stored at level 2 and level 3 in the attribute column (Q_Brand_ID or Type_Code_ID etc)--->
				<!--- Add only the required group attribute for sorting. There is no need to add all the attributes for sorting --->
				<cfif Groups_Exist eq 1 AND Field_Name neq "">
				
<cfsavecontent variable="tmpsql">
<cfloop from="1" to="#ArrayLen(arguments.stDataStructure.aProd)#" index="i">
<cfif arguments.stDataStructure.aProd[i].pricinglevel eq 1><cfset Field_Value = arguments.stDataStructure.aProd[i].MASTERITEMID>
<cfelse><cfset Field_Value = get_Attribute_Value('#Field_Name#','#arguments.stDataStructure.aProd[i].MASTERITEMID#')>
</cfif>insert into ##qTmp values(	'#left(arguments.stDataStructure.aProd[i].item,50)#','#left(arguments.stDataStructure.aProd[i].upc,50)#','#replace(left(arguments.stDataStructure.aProd[i].description,50),"'","","all")#','#arguments.stDataStructure.aProd[i].pricingLevel#','#replace(left(arguments.stDataStructure.aProd[i].displaygroupname,50),"'","","all")#','#Field_Value#','#left(arguments.stDataStructure.aProd[i].masterItemID,37)#','#arguments.stDataStructure.aProd[i].productGroupLevel#', '#left(arguments.stDataStructure.aProd[i].productGroupID,37)#', '#arguments.stDataStructure.aProd[i].isGroup#','#arguments.stDataStructure.aProd[i].EZButton_On_Default#',
'#arguments.stDataStructure.aProd[i].EZ_Contract_Id#','#arguments.stDataStructure.aProd[i].basesalescs#','#arguments.stDataStructure.aProd[i].GroupNumber#')<!--- D30357:Today's Price Wrong on Revision History END--->
</cfloop>
</cfsavecontent>

				<cfelse>

				<!--- If there are no groups --->
					<!--- <cfquery datasource="#application.datasource#"> --->
<cfsavecontent variable="tmpsql">
<cfloop from="1" to="#ArrayLen(arguments.stDataStructure.aProd)#" index="i">insert into ##qTmp values('#trim(left(arguments.stDataStructure.aProd[i].item,50))#','#trim(left(arguments.stDataStructure.aProd[i].upc,50))#','#trim(replace(left(arguments.stDataStructure.aProd[i].description,50),"'","","all"))#','#trim(arguments.stDataStructure.aProd[i].pricingLevel)#','#replace(trim(left(arguments.stDataStructure.aProd[i].displaygroupname,50)),"'","","all")#','#trim(left(arguments.stDataStructure.aProd[i].masterItemID,37))#','#trim(arguments.stDataStructure.aProd[i].productGroupLevel)#','#trim(left(arguments.stDataStructure.aProd[i].productGroupID,37))#','#trim(arguments.stDataStructure.aProd[i].isGroup)#','#trim(arguments.stDataStructure.aProd[i].EZButton_On_Default)#',
'#arguments.stDataStructure.aProd[i].EZ_Contract_Id#','#arguments.stDataStructure.aProd[i].basesalescs#','#arguments.stDataStructure.aProd[i].GroupNumber#') <!--- D30357:Today's Price Wrong on Revision History END---></cfloop>
</cfsavecontent>
					<!--- </cfquery> --->

				</cfif>
				<cfif trim(tmpsql) NEQ "">
					<cfquery datasource="#application.datasource#"><cfoutput>#preserveSingleQuotes(tmpsql)#</cfoutput></cfquery>
				</cfif>
				<!--- If there are no products --->
				<cfif Table_Created eq 0>
					<cfquery datasource="#application.datasource#">
						CREATE TABLE ##qTmp
							(
							oldArrayIndx  Int  Identity (1,1) PRIMARY KEY CLUSTERED,
							item varchar(50),
							upc varchar(50),
							description varchar(50),
							pricingLevel Int,
							displaygroupname varchar(50),
							masterItemID varchar(37),
							productGroupLevel INT,
							productGroupID VARCHAR(37),
							isGroup BIT,
							EZButton_On_Default BIT,
							Base_Sales_CS NVARCHAR(50),<!--- D30357:Today's Price Wrong on Revision History END--->
							groupNumber varchar(100)
							)
					</cfquery>
				</cfif>
		<cfcatch type="any">
			<cfrethrow>
		</cfcatch>
		</cftry>
		<cfscript>
			//get copies of the product and component value arrays to refer to when we shuffle the data
			aProdCopy = Duplicate(arguments.stDataStructure.aProd);

			if (ArrayLen(arguments.stDataStructure.aCompVal))
			{
				aCompValCopy = Duplicate(arguments.stDataStructure.aCompVal);
			}
		</cfscript>
		<!---sort on query--->
		<cftry>
		<cfquery name="qSort" datasource="#application.datasource#">
			SELECT	oldArrayIndx
			FROM	##qTmp
			ORDER BY #arguments.SortBy# #arguments.sortOrder#
		</cfquery>
		<!--- <cfquery datasource="#application.datasource#">
			drop table ##qTmp
		</cfquery> --->
		<cfcatch>
			<cfrethrow>
		</cfcatch>
		</cftry>
		<!---now loop over query and shuffle product and comp val--->
		<cfloop query="qSort">
			<cfscript>
				arguments.stDataStructure.aProd[CurrentRow] = aProdCopy[oldArrayIndx];
				if (isDefined("aCompValCopy") and ArrayLen(aCompValCopy))
				{
					arguments.stDataStructure.aCompVal[CurrentRow] = aCompValCopy[oldArrayIndx];
				}
			</cfscript>
		</cfloop>
		<cfreturn arguments.stDataStructure />
	</cffunction>

	<cffunction name="commit" output="true">

		<cfargument name="rebateData" type="struct" required="false" default="" />
		<cfargument name="fileName" type="string" required="false" default="" />
		<cfargument name="dynStatGroup" type="string" required="false" default="0" />
		<cfargument name="cacheData" type="boolean" required="false" default="1" />
		<cfargument name="dontCallSP" type="boolean" required="false" default="0" />
		<cfargument name="Display_Basis_Treatment_Code" required="false" default="0" />

		<!---set boolean value for groups--->
		<cfset var bHasGroups = 0 />
		<cfset var n = 0 />
		<cfset var i = 0 />
		<cfset var basisCodeType = 0 />
		<cfset arguments.cachedata = 0 />
		<cfset BasisCodeManager = CreateObject("component","components.Operating_Group.BasisCodeManager").init() />
		<!---sort the data structure by item before saving--->
			<cfset arguments.rebateData = this.sort(arguments.rebateData, "pricingLevel,item", "ASC") />
		<cfif NOT ArrayLen(arguments.rebateData.aProd)>
			<cfquery datasource="#application.datasource#">
				if object_id('tempdb..##qTmp') is not null
				Truncate table ##qTmp
			</cfquery>
		</cfif>

		<!---initialize rebate rules object--->
		<cfset rebateRules = CreateObject("component","components.programs.rebates.RebateComponentBusinessRule").init() />
		<!---get settings--->
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").get() />
		<cfquery datasource="#application.datasource#">
			if object_id('tempdb..##TMP_Program_Rebates_Component_Data') is not null
			drop table ##TMP_Program_Rebates_Component_Data
		</cfquery>
		<cfquery datasource="#application.datasource#">
			CREATE TABLE ##TMP_Program_Rebates_Component_Data
							(
							Program_Rebates_Component_ID INT,
							Program_Rebates_Product_Data_ID INT,
							rate DECIMAL(22,9),
							Unit_Of_Measure_Id INT,
							Program_Rebates_Component_Rule_ID INT,
							Is_Group BIT,
							Basis_Code_Quantity DECIMAL(22,9),
							Basis_Code_Quantity_UOM INT,
							Basis_Code_Free_Goods DECIMAL(22,9),
							Basis_Code_Free_Goods_UOM INT,
							Effective_Margin_Percent DECIMAL(22,9),
							Scan_UOM INT,
							Scan_Rate DECIMAL(22,9),
							Scan_Volume INT,
              				EZ_Contract_Max_Rate NVARCHAR(100)
							)
		</cfquery>
		<cftransaction action="begin" isolation="read_uncommitted">

			<!---set deleted to 1 for all tables in this transaction--->
			<cfquery datasource="#application.datasource#">
				--UPDATE 	Contract_Products
				--SET 	Deleted = 1
				DELETE FROM Contract_Products
				WHERE	Contract_Main_ID = #arguments.rebateData.programId#
				AND		Product_Type_ID = 2
				--AND		Deleted = 0
			</cfquery>

			<cfquery datasource="#application.datasource#">
				--UPDATE 	Contract_Product_Margin
				--SET 	Deleted = 1
				DELETE FROM Contract_Product_Margin
				WHERE	Contract_Main_ID = #arguments.rebateData.programId#
				AND		Product_Type_ID = 2
				--AND		Deleted = 0
			</cfquery>

			<cfquery datasource="#application.datasource#">
				--UPDATE 	Program_Rebates_Product_Data
				--SET 	Deleted = 1
				DELETE FROM Program_Rebates_Product_Data
				WHERE	program_id = #arguments.rebateData.programId#
				--AND		Deleted = 0
			</cfquery>

			<cfquery name="qGetCompIds" datasource="#application.datasource#">
				SELECT 	Program_Rebates_Component_ID
				FROM	Program_Rebates_Component
				WHERE	Program_ID = #arguments.rebateData.programId#
			</cfquery>

			<cfif qGetCompIds.RecordCount>

				<cfquery datasource="#application.datasource#">
					--UPDATE 	Program_Rebates_Component_Data
					--SET 	Deleted = 1
					DELETE FROM Program_Rebates_Component_Data
					WHERE	Program_Rebates_Component_ID in (#QuotedValueList(qGetCompIds.Program_Rebates_Component_ID)#)
					--AND		Deleted = 0
				</cfquery>

			</cfif>

			<cfquery datasource="#application.datasource#">
				--UPDATE 	Program_Rebates_Component
				--SET 	Deleted = 1
				DELETE FROM Program_Rebates_Component
				WHERE	Program_ID = #arguments.rebateData.programId#
				--AND		Deleted = 0
			</cfquery>

			<cfset allProductSelected = false>

			<cftransaction action="commit" />

		</cftransaction>

		<cftransaction action="begin" isolation="read_uncommitted">

			<!---if the dynStatGroup argument isn't = to 0 or 1, then let's get it from control panel options--->
			<cfif trim(arguments.dynStatGroup) neq 0 or trim(arguments.dynStatGroup) neq 1>

				<cfquery name="qCheckDynamic" datasource="#application.datasource#">
					SELECT	Program_Control_Panel_Options.Dynamic_Static_Groups
					FROM	Program_Control_Panel_Options
					INNER JOIN Contract_Main
					ON		Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
					AND 	Contract_Main.Contract_Main_ID = #arguments.rebateData.programId#
					WHERE	Program_Control_Panel_Options.Deleted = 0
				</cfquery>

				<cfset arguments.dynStatGroup = qCheckDynamic.Dynamic_Static_Groups />

			</cfif>

			<cfset aTmpHolder = ArrayNew(1) />
			<!---loop through data struct and insert data--->
			<cfloop index="n" from="1" to="#ArrayLen(arguments.rebateData.aComp)#">

				<cfparam name="arguments.rebateData.aComp[n].Claims_Mechanic" default="0" />

				<cfset useLakebaseForGetCompInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_component_name")>
<cfif useLakebaseForGetCompInfo>
	<cftry>
		<cfset GetCompInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_rebates_component_name", {
				"program_rebates_component_name_id" = "eq.#arguments.rebateData.aComp[n].compNameId#",
				"select" = "external_id"
			}), "external_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCompInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCompInfo>
<cfquery name="GetCompInfo" datasource="#application.datasource#" cachedwithin="#createtimespan(0,0,20,0)#">
				SELECT External_ID
				FROM Program_Rebates_Component_Name
				WHERE Program_Rebates_Component_Name_ID = '#arguments.rebateData.aComp[n].compNameId#'
				</cfquery>
</cfif>


				<cfquery name="qInsertComps" datasource="#application.datasource#">
					INSERT INTO	Program_Rebates_Component
						(
						Program_Rebates_Component_Name_ID,
						Program_ID,
						Component_Paid_To,
						GL_Account_ID,
						<cfif len(arguments.rebateData.aComp[n].Vendor_Master_ID) AND arguments.rebateData.aComp[n].Vendor_Master_ID NEQ 0>Vendor_Master_ID,</cfif>
						<cfif len(arguments.rebateData.aComp[n].VendorSelection) AND arguments.rebateData.aComp[n].VendorSelection NEQ 0>Vendor_Selection,</cfif>
						<cfif len(arguments.rebateData.aComp[n].Payee_Selection) AND arguments.rebateData.aComp[n].Payee_Selection NEQ 0>Payee_Type,</cfif>
						Claim_Mechanics,
						Basis_Code_Master_ID,
						Treatment_Code_Master_ID,
						Effective_Margin_Flag,
						Component_External_ID,
						Parent_Program_Rebates_Component_ID)
					VALUES
						(
						<cfqueryparam value="#arguments.rebateData.aComp[n].compNameId#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#arguments.rebateData.programId#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#arguments.rebateData.aComp[n].componentPaidTo#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#arguments.rebateData.aComp[n].GL_Account_ID#" cfsqltype="CF_SQL_VARCHAR">,
						<cfif len(arguments.rebateData.aComp[n].Vendor_Master_ID) AND arguments.rebateData.aComp[n].Vendor_Master_ID NEQ 0><cfqueryparam value="#arguments.rebateData.aComp[n].Vendor_Master_ID#" cfsqltype="CF_SQL_VARCHAR">,</cfif>
						<cfif len(arguments.rebateData.aComp[n].VendorSelection) AND arguments.rebateData.aComp[n].VendorSelection NEQ 0><cfqueryparam value="#arguments.rebateData.aComp[n].VendorSelection#" cfsqltype="CF_SQL_INTEGER">,</cfif>
						<cfif len(arguments.rebateData.aComp[n].Payee_Selection) AND arguments.rebateData.aComp[n].Payee_Selection NEQ 0><cfqueryparam value="#arguments.rebateData.aComp[n].Payee_Selection#" cfsqltype="CF_SQL_INTEGER">,</cfif>
						<cfqueryparam value="#arguments.rebateData.aComp[n].Claim_Mechanics#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#arguments.rebateData.aComp[n].BasisCode#" cfsqltype="CF_SQL_INTEGER" null="#arguments.rebateData.aComp[n].BasisCode EQ 0#">,
						<cfqueryparam value="#arguments.rebateData.aComp[n].TreatmentCode#" cfsqltype="CF_SQL_INTEGER" null="#arguments.rebateData.aComp[n].TreatmentCode EQ 0#">,
						<cfqueryparam value="#arguments.rebateData.aComp[n].EffectiveMarginFlag#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#GetCompInfo.External_ID#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#arguments.rebateData.aComp[n].ParentProgramRebatesComponentID#" cfsqltype="CF_SQL_INTEGER" null="#arguments.rebateData.aComp[n].ParentProgramRebatesComponentID EQ 0 OR NOT IsNumeric(arguments.rebateData.aComp[n].ParentProgramRebatesComponentID)#">
						)
				</cfquery>


				<!------ update discount type payment cycle ----->
				<!---<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
				 <cfset appSettings = genSettingsManager.get()> --->
				<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
				<cfif appSettings.getPaymentCycleAtDiscountType() AND len(trim(arguments.rebateData.aComp[n].PaymentCycle))>
					<cfset paymentCycleManager = CreateObject("component", "components.programs.PaymentCycleManager").init() />
					<cfset paymentCycleManager.savePaymentCycle(arguments.rebateData.programId, 2, arguments.rebateData.aComp[n].PaymentCycle,qInsertComps.Program_Rebates_Component_ID) />
				</cfif>

				<cfset aTmpHolder[n] = '#qInsertComps.Program_Rebates_Component_ID#' />

			</cfloop>


				<!------ Doing The delete again so that, there is no way of same product occuring twice,
					There was a bug (D22660) where there were multiple entries of same product, may be user double clicked :import selected products button ----->
				<cfquery name="qDeleteConProd" datasource="#application.datasource#">
					DELETE FROM Program_Rebates_Component_Data
					WHERE	Program_Rebates_Product_Data_ID IN
					(
					SELECT	Program_Rebates_Product_Data_ID
					FROM 	Program_Rebates_Product_Data
					WHERE	Program_ID = #arguments.rebateData.programId#
					)

					DELETE FROM Program_Rebates_Product_Data
					WHERE	Program_ID = #arguments.rebateData.programId#

					DELETE FROM Contract_Products
					WHERE	Contract_Main_ID = #arguments.rebateData.programId#
					AND		Product_Type_ID = 2
				</cfquery>

				<!------ Products / Group Level 1 ----->
				<cfquery name="qInsertConProd" datasource="#application.datasource#">
					<!------ Doing The delete again so that, there is no way of same product occuring twice,
					There was a bug (D6770) where there were multiple entries of same product, may be user double clicked save button ----->
					<!--- UPDATE 	Contract_Products
					SET 	Deleted = 1
					WHERE	Contract_Main_ID = #arguments.rebateData.programId#
					AND		Product_Type_ID = 2
					AND		Deleted = 0
					AND		BSA_Foodservice_Items_Master_ID = '#arguments.rebateData.aProd[i].masterItemID#'
					AND		Pricing_Level_ID = #arguments.rebateData.aProd[i].pricingLevel# --->


					INSERT INTO	Contract_Products
						(
							Contract_Main_ID,
							Product_Type_ID,
							BSA_Foodservice_Items_Master_ID,
							Product_Group_Level_ID,
							Product_Group_ID,
							Pricing_Level_ID,
							Is_Group,
							Dynamic_Static_Groups,
							EZButton_On_Default,
              				EZ_Contract_ID,
              				Base_Sales_CS)<!--- D30357:Today's Price Wrong on Revision History END--->
					SELECT
							'#arguments.rebateData.programId#',
							2,
							Tmp.masterItemID,
							Tmp.productGroupLevel,
							Tmp.productGroupID,
							Tmp.pricingLevel,
							Tmp.isGroup,
							#arguments.dynStatGroup#,
							Tmp.EZButton_On_Default,
              				Tmp.EZ_Contract_ID,
              				Base_Sales_CS<!--- D30357:Today's Price Wrong on Revision History END--->
					FROM ##qTmp Tmp
					ORDER BY pricingLevel,item ASC
					<!--- VALUES
							(
							'#arguments.rebateData.programId#',
							2,
							'#arguments.rebateData.aProd[i].masterItemID#',
							#arguments.rebateData.aProd[i].productGroupLevel#,
							'#arguments.rebateData.aProd[i].productGroupID#',
							#arguments.rebateData.aProd[i].pricingLevel#,
							#arguments.rebateData.aProd[i].isGroup#,
							#arguments.dynStatGroup#,
							#arguments.rebateData.aProd[i].EZButton_On_Default#
							) --->
				</cfquery>

				<cfquery name="qInsertProdData" datasource="#application.datasource#">
					INSERT INTO	Program_Rebates_Product_Data
						(
							Program_ID,
							Contract_Products_ID,
							Volume,
							Unit_Of_Measure_ID,
							Is_Group
						)
					SELECT
							CP.Contract_Main_ID,
							CP.Contract_Products_ID,
							0,
							2,
							CP.Is_Group
					FROM Contract_Products CP
					WHERE 	CP.Contract_Main_ID = '#arguments.rebateData.programId#' AND
							CP.Product_Type_ID =2 AND
							CP.DELETED = 0
						order by contract_products_id desc
				<!--- 	VALUES
						(	'#arguments.rebateData.programId#',
							'#qInsertConProd.Contract_Products_ID#',
							'#arguments.rebateData.aProd[i].volume#',
							2,
							#arguments.rebateData.aProd[i].isGroup#) --->
				</cfquery>

		<cfloop index="i" from="1" to="#ArrayLen(arguments.rebateData.aProd)#">

				<!---handle for empty pricing levels--->
				<cfif not isNumeric(arguments.rebateData.aProd[i].pricingLevel)>
					<cfset arguments.rebateData.aProd[i].pricingLevel = 1 />
				</cfif>

				<cfif arguments.rebateData.aProd[i].productGroupLevel EQ 1>
					<cfset allProductSelected = true>
				</cfif>

				<!---if we have groups the flag for it--->
				<cfif arguments.rebateData.aProd[i].isGroup EQ 1>
					<cfset bHasGroups = 1>
				</cfif>
				<!---now loop through components--->
				<cfloop index="n" from="1" to="#ArrayLen(arguments.rebateData.aComp)#">
					<cfif ArrayLen(arguments.rebateData.aCompVal)>
						<cfset basisCodeType = 0 />

						<cfif arguments.Display_Basis_Treatment_Code EQ 1>
							<cfif BasisCodeManager.getBasicCodeType(arguments.rebateData.aComp[n].BasisCode) EQ "Y">
								<cfset basisCodeType = 1 />
							</cfif>
						</cfif>
						<!---param rule id --->
						<cfparam name="arguments.rebateData.aCompVal[i][n].ruleId" default="0" />
						<!---set rule id to 0 if it's an empty string--->
						<cfif trim(arguments.rebateData.aCompVal[i][n].ruleId) eq "">
							<cfset arguments.rebateData.aCompVal[i][n].ruleId = 0 />
						</cfif>

						<CFIF TRIM(arguments.rebateData.aCompVal[i][n].rate) EQ "">
							<CFSET arguments.rebateData.aCompVal[i][n].rate = 0>
						</CFIF>
						<cfif basisCodeType EQ 1>
							<CFSET arguments.rebateData.aCompVal[i][n].rate = 0>
						</cfif>
						<!---get the rebate rule data for this component--->
						<cfset qGetCompRuleData = rebateRules.getComponentRules(arguments.rebateData.aComp[n].compNameId,1) />

						<!---if the rebate rule is required and the uom's match then set the rebate rule id--->
						<cfif qGetCompRuleData.Unit_Of_Measure_ID eq arguments.rebateData.aCompVal[i][n].uomId and arguments.rebateData.aComp[n].rulesRequired eq 1>
							<cfset arguments.rebateData.aCompVal[i][n].ruleId = qGetCompRuleData.Joined_Rule_Id />
						<!---if they don't match, then set it to zero--->
						<cfelseif qGetCompRuleData.Unit_Of_Measure_ID neq arguments.rebateData.aCompVal[i][n].uomId>
							<cfset arguments.rebateData.aCompVal[i][n].ruleId = 0 />
						</cfif>

						<cfif Not isNumeric(arguments.rebateData.aCompVal[i][n].uomId) >
							<cfset arguments.rebateData.aCompVal[i][n].uomId = ListFirst(arguments.rebateData.aCompVal[i][n].uomId) >
						</cfif>

						<cfif Not isNumeric(arguments.rebateData.aCompVal[i][n].rate) >
							<cfset arguments.rebateData.aCompVal[i][n].rate = ListFirst(arguments.rebateData.aCompVal[i][n].rate) >
						</cfif>

						<cfif Not isNumeric(arguments.rebateData.aCompVal[i][n].effectMarginPercent) OR arguments.rebateData.aComp[n].EffectiveMarginFlag EQ 0 >
							<cfset arguments.rebateData.aCompVal[i][n].effectMarginPercent = 100 />
						</cfif>

						<cfset rate = arguments.rebateData.aCompVal[i][n].rate />
						<cfset uomId = arguments.rebateData.aCompVal[i][n].uomId />
						<!----- for scan components if the uom selected by the user is "each", we store the rate entered by the user in the scan rate field
						and will store the rate converted to product UOM in the regular rate fields so that we do not have to change the rest of the application for now.
						once we have logic to handle uom="each" in other parts of the app we can remove the following conversion.

						if rebate type = Variable/Fixed Combo and uom=EA
						----->
						 <cfif arguments.rebateData.aComp[n].rebate_type eq 4 and arguments.rebateData.aCompVal[i][n].uomId eq 5>
						 	<cfset uomId = 1 />
							<cfif arguments.rebateData.aProd[i].productInventoryUOM EQ "LB"><cfset uomId = 2 /></cfif>
							<cfset rate = arguments.rebateData.aCompVal[i][n].rate * arguments.rebateData.aProd[i].EAConversion />
						 </cfif>

					<!--- if the uomID is null or 0 then grab the value from the template --->
						<cfif ((uomId EQ "" OR uomId EQ 0) AND (arguments.rebateData.programId NEQ ""))>
							<cfset qryUOM = getUOMfromTemplate(arguments.rebateData.programId) />
							<cfset uomId = qryUOM.rateTypeDefault />
						</cfif>

						<!--- UPDATE  Program_Rebates_Product_Data LABEL D28445 --->
						<cfset this.updRebateProductData(	arguments.rebateData.programId,
															qInsertProdData.Program_Rebates_Product_Data_ID[i],
															arguments.rebateData.aProd[i].Competitor_Price,
															arguments.rebateData.aProd[i].Competitor_Name_ID,
															arguments.rebateData.aProd[i].Competitor_Time_Frame,
															'') />
						<cfquery name="qInsertCompDataTmp" datasource="#application.datasource#">
							INSERT INTO	##TMP_Program_Rebates_Component_Data
								(
								Program_Rebates_Component_ID,
								Program_Rebates_Product_Data_ID,
								rate,
								Unit_Of_Measure_Id,
								Program_Rebates_Component_Rule_ID,
								Is_Group,
								Basis_Code_Quantity,
								Basis_Code_Quantity_UOM,
								Basis_Code_Free_Goods,
								Basis_Code_Free_Goods_UOM,
								Effective_Margin_Percent,
								Scan_UOM,
								Scan_Rate,
								Scan_Volume,
                				EZ_Contract_Max_Rate
								)
							VALUES
								(
								'#aTmpHolder[n]#',
								'#qInsertProdData.Program_Rebates_Product_Data_ID[i]#',
								<cfif uomId eq 1>
								 '#NumberFormat(rate, "_.__")#'
								 <cfelse>
									'#rate#'
								</cfif>
								,
								'#uomId#',
								#arguments.rebateData.aCompVal[i][n].ruleId#,
								#arguments.rebateData.aProd[i].isGroup#,
								<cfqueryparam value="#arguments.rebateData.aCompVal[i][n].basisCodeQuantity#" cfsqltype="CF_SQL_FLOAT" null="#Not IsNumeric(arguments.rebateData.aCompVal[i][n].basisCodeQuantity)#">,
								<cfqueryparam value="#arguments.rebateData.aCompVal[i][n].basisCodeQuantityUom#" cfsqltype="CF_SQL_INTEGER" null="#Not IsNumeric(arguments.rebateData.aCompVal[i][n].basisCodeQuantityUom)#">,
								<cfqueryparam value="#arguments.rebateData.aCompVal[i][n].basisCodeFreeGoods#" cfsqltype="CF_SQL_FLOAT" null="#Not IsNumeric(arguments.rebateData.aCompVal[i][n].basisCodeFreeGoods)#">,
								<cfqueryparam value="#arguments.rebateData.aCompVal[i][n].basisCodeQuantityUom#" cfsqltype="CF_SQL_INTEGER" null="#Not IsNumeric(arguments.rebateData.aCompVal[i][n].basisCodeQuantityUom)#">,
								<cfqueryparam value="#arguments.rebateData.aCompVal[i][n].effectMarginPercent#" cfsqltype="CF_SQL_FLOAT">,
								<cfqueryparam value="#arguments.rebateData.aCompVal[i][n].uomId#" cfsqltype="CF_SQL_INTEGER" null="#Not IsNumeric(arguments.rebateData.aCompVal[i][n].uomId)#">,
								<cfqueryparam value="#arguments.rebateData.aCompVal[i][n].rate#" cfsqltype="CF_SQL_FLOAT" null="#Not IsNumeric(arguments.rebateData.aCompVal[i][n].rate)#">,
								<cfqueryparam value="#arguments.rebateData.aCompVal[i][n].scanVolume#" cfsqltype="CF_SQL_DECIMAL" null="#arguments.rebateData.aCompVal[i][n].scanVolume EQ 0 OR IsNumeric(arguments.rebateData.aCompVal[i][n].scanVolume) EQ 0#">,
                <cfqueryparam value="#arguments.rebateData.aCompVal[i][n].maxRate#" cfsqltype="CF_SQL_FLOAT" null="#IsNumeric(arguments.rebateData.aCompVal[i][n].maxRate) EQ 0#">
                )

						</cfquery>
					</cfif>
				</cfloop>
			</cfloop>

			<cfquery name="qInsertCompData" datasource="#application.datasource#">
					INSERT INTO	Program_Rebates_Component_Data
							(
							Program_Rebates_Component_ID,
							Program_Rebates_Product_Data_ID,
							rate,
							Unit_Of_Measure_Id,
							Program_Rebates_Component_Rule_ID,
							Is_Group,
							Basis_Code_Quantity,
							Basis_Code_Quantity_UOM,
							Basis_Code_Free_Goods,
							Basis_Code_Free_Goods_UOM,
							Effective_Margin_Percent,
							Scan_UOM,
							Scan_Rate,
							Scan_Volume,
              				EZ_Contract_Max_Rate
							)
					SELECT
							Program_Rebates_Component_ID,
							Program_Rebates_Product_Data_ID,
							rate,
							Unit_Of_Measure_Id,
							Program_Rebates_Component_Rule_ID,
							Is_Group,
							Basis_Code_Quantity,
							Basis_Code_Quantity_UOM,
							Basis_Code_Free_Goods,
							Basis_Code_Free_Goods_UOM,
							Effective_Margin_Percent,
							Scan_UOM,
							Scan_Rate,
							Scan_Volume,
              EZ_Contract_Max_Rate
					FROM ##TMP_Program_Rebates_Component_Data

				</cfquery>
			<cfif allProductSelected>
				<cfset ProductGroupManager.updateOtherAvgProductVolume(arguments.rebateData.programId) />
			</cfif>

			<!---check for revision--->
			<cfquery name="qCheckIfRevision" datasource="#application.datasource#">
				SELECT	Is_A_Revision
				FROM 	Contract_Main
				WHERE	Deleted = 0
				AND		Contract_Main_ID = #arguments.rebateData.programId#
			</cfquery>

			<!---check if it's a bid request--->
			<cfquery name="qCheckIfBidRequest" datasource="#application.datasource#">
				SELECT	Program_ID
				FROM 	Program_Bid_Request
				WHERE	Deleted = 0
				AND		Program_ID = #arguments.rebateData.programId#
			</cfquery>

			<!---if it's a revision and a bid request then call the setStatusOnRevision() function in the BidRequestProductStatusManager--->
			<cfif qCheckIfRevision.Is_A_Revision eq 1 and qCheckIfBidRequest.RecordCount>

				<cfset createObject("component", "components.programs.bid_request.BidRequestProductStatusManager").setStatusOnRevision(arguments.rebateData.programId) />

			</cfif>

			<!---flag groups to be processed if adding groups--->
			<cfif bHasGroups>

				<cfset useLakebaseForqFlagGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqFlagGroup>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"deleted" = "eq.0",
				"contract_main_id" = "eq.#arguments.rebateData.programId#"
			},
			{
				"group_processed" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqFlagGroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqFlagGroup>
<cfquery name="qFlagGroup" datasource="#application.datasource#">

					UPDATE	Contract_Main
					SET		Group_Processed = 1
					WHERE	Deleted = 0
					AND 	Contract_Main_ID = #arguments.rebateData.programId#

				</cfquery>
</cfif>

			<!---call SP to update program product volume --->
			<cfelseif isDefined("arguments.dontCallSP") and arguments.dontCallSP neq 1>    <!---31869 - do not call when program has product groups as it would wipe out entered volume information for product members--->
				<cfstoredproc procedure="PROGRAM_PRODUCT_VOLUME_UPD" datasource="#application.datasource#">
					<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#arguments.rebateData.programId#" null="no">
				</cfstoredproc>
			</cfif>

			<cftransaction action="commit" />

		</cftransaction>

		<!---cache the data to a file if argument is 1--->
		<cfif arguments.cacheData eq 1>
			<cfwddx action="cfml2wddx" input="#arguments.rebateData#" output="tmpDataPacket">
			<cftry>

				<cflock timeout="10" type="exclusive">
					<cffile action="write" file="#request.app_general_functions.Get_Document_Path()#\data_Files\created\contracts\RebateData\#arguments.rebateData.programId#.xml" output="#tmpDataPacket#">
				</cflock>

			<cfcatch type="any">
				<cfoutput><b>#cfcatch.Detail#</b></cfoutput>
			</cfcatch>

			</cftry>
		</cfif>

	</cffunction>

	<cffunction name="getUOMfromTemplate" output="false" returntype="query">
		<cfargument name="programID" type="numeric" required="true" />

		<cfquery name="qryUOM" datasource="#application.datasource#">
			 SELECT PCPO.rateTypeDefault
			 FROM
			 Contract_Main CM
			 INNER JOIN Program_Control_Panel_Options PCPO ON CM.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID
			 WHERE CM.Contract_Main_ID = #arguments.programID#
		</cfquery>

		<cfreturn qryUOM />
	</cffunction>

	<cffunction name="addToGroupLevel" output="false">

		<cfargument name="groupLevelId" type="numeric" required="true" />
		<cfargument name="pricingLevelId" type="numeric" required="true" />

		<cfif NOT isDefined("this.stRebate.aGroupLevel")>
			<cfset initialiseGroupLevel() />
		</cfif>

		<cfif arguments.pricingLevelId gt 0 and pricingLevelId lte 3>
			<cfset this.stRebate.aGroupLevel[arguments.pricingLevelId] = arguments.groupLevelId />
		</cfif>

	</cffunction>

	<cffunction name="initialiseGroupLevel" output="false">

		<cfset this.stRebate.aGroupLevel = ArrayNew(1) />
		<cfset this.stRebate.aGroupLevel[1] = "" />
		<cfset this.stRebate.aGroupLevel[2] = "" />
		<cfset this.stRebate.aGroupLevel[3] = "" />

	</cffunction>

	<cffunction name="deleteProgramXML" access="public" output="false" returntype="void">
	 <cfargument name="programId" type="Any" required="true" />

	  <cftry>
	  <cfif FileExists("#request.app_general_functions.Get_Document_Path()#\data_files\created\contracts\RebateData\#arguments.programId#.xml")>
		<cflock timeout="10" type="exclusive">
		  <cffile action="delete" file="#request.app_general_functions.Get_Document_Path()#\data_files\created\contracts\RebateData\#arguments.programId#.xml" />
		</cflock>
		</cfif>
			<cfcatch type="any">
				<cfoutput><b>#cfcatch.Detail#</b></cfoutput>
			</cfcatch>

			</cftry>
	</cffunction>

	<cffunction Name="getMaxProducts" access="public" output="false" returntype="numeric">
		<cfif NOT isdefined("request.Max_Program_product_Display")>
			<cfset useLakebaseForqGetMaxProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_settings")>
<cfif useLakebaseForqGetMaxProducts>
	<cftry>
		<cfset qGetMaxProducts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users_settings", {
				"user_id" = "eq.#request.accessstructure.company_Main_Id#",
				"select" = "max_program_product_display"
			}), "max_program_product_display"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetMaxProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetMaxProducts>
<cfquery name="qGetMaxProducts" datasource="#application.datasource#">
				Select		Max_Program_product_Display
				From		_Users_Settings
				Where		User_ID		=	'#request.accessstructure.company_Main_Id#'
			</cfquery>
</cfif>
			<cfset request.Max_Program_product_Display = qGetMaxProducts.Max_Program_product_Display />
		</cfif>
		<!---Label - 21880: if request.Max_Program_product_Display is not numeric then defualt it to 250 --->
		<cfif not isNumeric(request.Max_Program_product_Display)>
			<cfset request.Max_Program_product_Display = 250 />
		</cfif>
		<cfreturn request.Max_Program_product_Display />
	</cffunction>

	<cffunction Name="delSingleProd" access="public" output="false" returntype="Array">
	  <!--- 27063 - CF 9 puts the passing Ajax array argument in position 2, CF 8 puts in position 1!!
	        Replaced the hard-coded of arguments[1] with a call to getArrayArgument() to find
	        the array data needed to process --->
		<cfset var argArray = getArrayArgument( arguments ) />
		<cfset var conProdId 	= argArray[1] />
		<cfset var action 		= argArray[2] />
		<cfset var bAutoAddComponent = argArray[3] />
		<cfset var retArray 	= arrayNew(1) />
		<cfquery name="qDelRebateProduct1" datasource="#application.datasource#">
			--DELETE
			--FROM
			UPDATE Program_Rebates_Component_Data
				SET DELETED = 1
			WHERE		Program_Rebates_Product_Data_ID	IN
					(SELECT Program_Rebates_Product_Data_ID
					 FROM Program_Rebates_Product_Data
					 WHERE Contract_Products_Id  = '#conProdId#')
		</cfquery>
		<cfquery name="qDelRebateProduct2" datasource="#application.datasource#">
			--DELETE
			--FROM
			UPDATE Program_Rebates_Product_Data
			SET DELETED = 1
			WHERE Contract_Products_Id  = '#conProdId#'
		</cfquery>
        	<!--- Dev Note: drachala;  D27947: Deleted Product Groups and Capture START --->
			<cfset useLakebaseForqIsGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForqIsGroup>
	<cftry>
		<cfset qIsGroup = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"contract_products_id" = "eq.#conProdId#",
				"select" = "is_group,product_group_id,product_type_id,contract_main_id"
			}), "is_group,product_group_id,product_type_id,contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqIsGroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqIsGroup>
<cfquery name="qIsGroup" datasource="#application.datasource#">
			SELECT is_group,Product_group_id,Product_Type_ID, contract_main_id
			FROM Contract_Products
			WHERE contract_Products_Id  = '#conProdId#'
			</cfquery>
</cfif>
			<!--- Dev Note: drachala;  D27947: Deleted Product Groups and Capture END --->

		<cfquery name="qDelRebateProduct3" datasource="#application.datasource#">
			--DELETE
			--FROM
			UPDATE Contract_Products
			SET DELETED = 1
			<!--- Dev Note: drachala;  D27947: Deleted Product Groups and Capture START --->
			<cfif qIsGroup.is_group>
				WHERE Contract_Main_ID = #qIsGroup.contract_main_id#
				AND Product_group_id = '#qIsGroup.Product_group_id#'
				AND Product_Type_ID = #qIsGroup.Product_Type_ID#
				AND Deleted = 0
			<cfelse>
			WHERE Contract_Products_Id  = '#conProdId#'
			</cfif>
			<!--- Dev Note: drachala;  D27947: Deleted Product Groups and Capture END --->
		</cfquery>


		<cfset useLakebaseForgetProgID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForgetProgID>
	<cftry>
		<cfset getProgID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"contract_products_id" = "eq.#conProdId#",
				"select" = "contract_main_id"
			}), "contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetProgID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetProgID>
<cfquery name="getProgID" datasource="#application.datasource#">
		 SELECT Contract_Main_ID
		 FROM Contract_Products
		 WHERE Contract_Products_ID = '#conProdId#'
		</cfquery>
</cfif>
		<!---
			28993/Anand Rao/28-Oct-2011
			Single component changes
		--->
		<cfif (getProgID.RecordCount GTE 1 AND bAutoAddComponent EQ 1)>
			<cfquery name="getProductpresent" datasource="#application.datasource#">
				SELECT 	PRCD.Program_Rebates_Product_Data_ID
				FROM 	Program_Rebates_Product_Data PRPD
				INNER JOIN Program_Rebates_Component_Data PRCD ON
						PRCD.Program_Rebates_Product_Data_ID = PRPD.Program_Rebates_Product_Data_ID
	 			WHERE 	PRPD.Program_ID = #getProgID.Contract_Main_ID#
				AND		PRPD.Deleted = 0
			</cfquery>
			<cfif getProductpresent.Recordcount EQ 0>
				<cfset useLakebaseForupdPrgRebComp = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_component")>
<cfif useLakebaseForupdPrgRebComp>
	<cftry>
		<cfset application.oLakebase.updateRows("program_rebates_component",
			{
				"program_id" = "eq.#getProgID.Contract_Main_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdPrgRebComp = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdPrgRebComp>
<cfquery name="updPrgRebComp" datasource="#application.datasource#">
					UPDATE Program_Rebates_Component
					SET Deleted = 1
					WHERE Program_ID = #getProgID.Contract_Main_ID#
				</cfquery>
</cfif>
			</cfif>
		</cfif>

		<cfset UpdStatus = UpdateGroupStatus('#getProgID.Contract_Main_ID#')>

		<cfset retArray[1] = conProdId />
		<cfset retArray[2] = action /> <!--- 1 for delete --->
		<cfreturn retArray />
	</cffunction>

	<cffunction Name="unDelSingleProd" access="public" output="false" returntype="array">
	  <!--- 27063 - CF 9 puts the passing Ajax array argument in position 2, CF 8 puts in position 1!!
	        Replaced the hard-coded of arguments[1] with a call to getArrayArgument() to find
	        the array data needed to process --->
		<cfset var argArray = getArrayArgument( arguments ) />
		<cfset var conProdId 	= argArray[1] />
		<cfset var action 		= argArray[2] />
		<cfset var bAutoAddComponent = argArray[3] />
		<cfset var retArray 	= arrayNew(1) />
		<cfquery name="qUnDelRebateProduct1" datasource="#application.datasource#">
			--DELETE
			--FROM
			UPDATE Program_Rebates_Component_Data
				SET DELETED = 0
			WHERE		Program_Rebates_Product_Data_ID	IN
					(SELECT Program_Rebates_Product_Data_ID
					 FROM Program_Rebates_Product_Data
					 WHERE Contract_Products_Id  = '#conProdId#')
		</cfquery>
		<cfquery name="qUnDelRebateProduct2" datasource="#application.datasource#">
			--DELETE
			--FROM
			UPDATE Program_Rebates_Product_Data
			SET DELETED = 0
			WHERE Contract_Products_Id  = '#conProdId#'
		</cfquery>

		<cfquery name="qUnDelRebateProduct3" datasource="#application.datasource#">
			--DELETE
			--FROM
			UPDATE Contract_Products
			SET DELETED = 0
			WHERE Contract_Products_Id  = '#conProdId#'
		</cfquery>

		<cfquery name="getProgID" datasource="#application.datasource#">
		 SELECT Contract_Main_ID
		 FROM Contract_Products
		 WHERE Contract_Products_ID = '#conProdId#'
		</cfquery>
		<!---
			28993/Anand Rao/28-Oct-2011
			Single component changes
		--->
		<cfif (getProgID.RecordCount GTE 1 AND bAutoAddComponent EQ 1)>
			<cfquery name="updPrgRebComp" datasource="#application.datasource#">
			UPDATE Program_Rebates_Component
			SET Deleted = 0
			WHERE Program_ID = #getProgID.Contract_Main_ID#
			</cfquery>
		</cfif>
		<cfset retArray[1] = conProdId />
		<cfset retArray[2] = action /> <!--- 1 for delete --->
		<cfreturn retArray />
	</cffunction>

	<cffunction Name="saveComponentInformation" access="public" output="false" returntype="void">
		<cfargument name="aComp" type="struct" required="true" />

		<cfquery name="GetCompInfo" datasource="#application.datasource#" cachedwithin="#createtimespan(0,0,20,0)#">
			SELECT 	External_ID
			FROM 	Program_Rebates_Component_Name
			WHERE 	Program_Rebates_Component_Name_ID = '#aComp.compNameId#'
		</cfquery>

		<cfquery name="qUpdRebateComponent" datasource="#application.datasource#">
			UPDATE	Program_Rebates_Component
			SET		Program_Rebates_Component_Name_ID = <cfqueryparam value="#aComp.compNameId#" cfsqltype="CF_SQL_INTEGER">,
					Component_Paid_To = <cfqueryparam value="#aComp.componentPaidTo#" cfsqltype="CF_SQL_INTEGER">,
					GL_Account_ID = <cfqueryparam value="#aComp.GL_Account_ID#" cfsqltype="CF_SQL_VARCHAR">,
					Vendor_Master_ID = <cfif len(aComp.Vendor_Master_ID) AND aComp.Vendor_Master_ID NEQ 0><cfqueryparam value="#aComp.Vendor_Master_ID#" cfsqltype="CF_SQL_VARCHAR"><cfelse>NULL</cfif>,
					Vendor_Selection = <cfif len(aComp.VendorSelection) AND aComp.VendorSelection NEQ 0><cfqueryparam value="#aComp.VendorSelection#" cfsqltype="CF_SQL_INTEGER"><cfelse>NULL</cfif>,
					Payee_Type = <cfif len(aComp.Payee_Selection) AND aComp.Payee_Selection NEQ 0><cfqueryparam value="#aComp.Payee_Selection#" cfsqltype="CF_SQL_INTEGER"><cfelse>NULL</cfif>,
					Claim_Mechanics = <cfqueryparam value="#aComp.Claim_Mechanics#" cfsqltype="CF_SQL_INTEGER">,
					Basis_Code_Master_ID = <cfqueryparam value="#aComp.BasisCode#" cfsqltype="CF_SQL_INTEGER" null="#aComp.BasisCode EQ 0#">,
					Treatment_Code_Master_ID = <cfqueryparam value="#aComp.TreatmentCode#" cfsqltype="CF_SQL_INTEGER" null="#aComp.TreatmentCode EQ 0#">,
					Effective_Margin_Flag = <cfqueryparam value="#aComp.EffectiveMarginFlag#" cfsqltype="CF_SQL_INTEGER">,
					Component_External_ID = <cfqueryparam value="#GetCompInfo.External_ID#" cfsqltype="CF_SQL_VARCHAR">,
					Parent_Program_Rebates_Component_ID = <cfqueryparam value="#aComp.ParentProgramRebatesComponentID#" cfsqltype="CF_SQL_INTEGER" null="#aComp.ParentProgramRebatesComponentID EQ 0 OR NOT IsNumeric(aComp.ParentProgramRebatesComponentID)#">
			WHERE	Program_Rebates_Component_ID = <cfqueryparam value="#arguments.aComp.compID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

	</cffunction>

	<cffunction Name="saveProdRate" access="public" output="true" returntype="array">
	  <!--- 27063 - CF 9 puts the passing Ajax array argument in position 2, CF 8 puts in position 1!!
          Replaced the hard-coded of arguments[1] with a call to getArrayArgument() to find
          the array data needed to process --->
	  <cfset var argArray = getArrayArgument( arguments ) />
		<cfset var rate			= argArray[1] />
		<cfset var uom 			= argArray[2] />
		<cfset var prodCompId 	= argArray[3] />
		<cfset var scanVolume 	= '' />
		<cfset var ruleId 	= argArray[7] />
		<cfset var scanRate 	= '' />
		<cfset var scanUom 	= '' />
		<cfset var argSaveScanVolume 	= arguments[2] />
		<cfset var Competitor_Price		= argArray[10] />
		<cfset var Competitor_Name_ID 	= argArray[11] />
		<cfset var Competitor_Time_Frame = argArray[12] />
		<cfset var CompetitorSourceOther = argArray[13] />
		<cfif argSaveScanVolume>
			<cfset scanVolume 	= argArray[6] />
			<cfset scanRate 	= argArray[8] />
			<cfset scanUom 	= argArray[9] />
		</cfif>

	<!---D38536  :: Alternate recapture rates per component START--->
		<cfset var alternaterecapturerate = argArray[14]/>
		<cfset var contract_products_id = argArray[15]/>
		<cfset ar_rate = argArray[16] />
		<cfset ar_uom = argArray[17] />
		<cfset compnameid = argArray[18] />
   <!---D38536  :: Alternate recapture rates per component END	--->
	<!--- D38846 ::  Recapture changes START --->
	<cfif arraylen(argArray) GT 18 AND ArrayIsDefined(argArray, 19)>
			<cfset MassApply = argArray[19] />
	<cfelse>
			<cfset MassApply = 0>
	</cfif>
	<!--- D38846 ::  Recapture changes END--->
		<cfif trim(rate) eq ''>
				<cfset rate = 0 />
		</cfif>

		<cfset prodCompId 	= argArray[3] />
		<cfquery name="getProgID" datasource="#application.datasource#">
		 SELECT prc.Program_ID, prc.Program_Rebates_Component_ID
		 FROM Program_Rebates_Component_Data prcd
		 INNER JOIN Program_Rebates_Component prc
		 ON prcd.Program_Rebates_Component_ID = prc.Program_Rebates_Component_ID
		 WHERE prcd.Program_Rebates_Component_Data_ID = '#prodCompId#'
		</cfquery>
		<!--- <cfset var source	 	= argArray[4] /> --->
		<cfquery name="qUpdRebateProduct" datasource="#application.datasource#">
			UPDATE	Program_Rebates_Component_Data
				SET		Rate = '#rate#',
						Unit_Of_Measure_ID = '#uom#'
					<cfif argSaveScanVolume>
					,Scan_Rate = <cfqueryparam value="#scanRate#" cfsqltype="cf_sql_float" null="#scanRate EQ 0 OR IsNumeric(scanRate) EQ 0#">
					,Scan_UOM =  <cfqueryparam value="#scanUom#" cfsqltype="cf_sql_integer" null="#scanRate EQ 0 OR IsNumeric(scanRate) EQ 0#">
					,Scan_Volume = <cfqueryparam value="#scanVolume#" cfsqltype="cf_sql_decimal" null="#scanVolume EQ 0 OR IsNumeric(scanVolume) EQ 0#">
					</cfif>
					,Program_Rebates_Component_Rule_ID = '#ruleId#'
			OUTPUT INSERTED.Program_Rebates_Product_Data_ID
			WHERE	Program_Rebates_Component_Data_ID = '#prodCompId#'
		</cfquery>

		<!--- UPDATE  Program_Rebates_Product_Data LABEL D28445 --->
			<cfset this.updRebateProductData(	getProgID.Program_ID,
												qUpdRebateProduct.Program_Rebates_Product_Data_ID,
												Competitor_Price,
												Competitor_Name_ID,
												Competitor_Time_Frame,
												CompetitorSourceOther) />
<!--- D38846 ::  Recapture changes START-
<cfif arraylen(argArray) GT 18 AND ArrayIsDefined(argArray, 19)>
				<cfset this.InsertMassApplyAlternateRates(compnameid,
																							getProgID.Program_Rebates_Component_ID,
																							getProgID.Program_ID,
																							Contract_products_id,
																							MassApply,
																							ar_rate,
																							ar_uom
					) />
<cfelse>	--->
	<!---D38536  :: Alternate recapture rates per component START --->
<cfif MassApply EQ 0>
			<cfset this.InsertAlternateRates(compnameid,
																	getProgID.Program_Rebates_Component_ID,
																	getProgID.Program_ID,
																	Contract_products_id,
																	ar_rate,
																	ar_uom,
																	rate,
																	uom
					) />
</cfif>
	<!---D38536  :: Alternate recapture rates per component END --->
<!---</cfif>
 D38846 ::  Recapture changes END--->

		<cfreturn argArray />
	</cffunction>

  	<cffunction name="getArrayArgument" output="false" hint="Returns the first array argument in the arguments structure.">
    <cfscript>
      var idx = 0;
      // search for array in the passing argument (note: arguments is an array of an array)
      for ( idx=1;  idx LTE ArrayLen(arguments[ 1 ]);  idx=idx+1 ) {
        // found the first array element, bail out
        if ( IsArray(arguments[ 1 ][ idx ]) ) {
          return arguments[ 1 ][ idx ];
        }
      }
      // no array is found in the passing argument structure, return a bizzare number
      return -1;
    </cfscript>
  	</cffunction>

	<cffunction Name="saveProdRate_All" access="public" output="false" returntype="array">
	  <!--- 27063 - CF 9 puts the passing Ajax array argument in position 2, CF 8 puts in position 1!!
	        Replaced the hard-coded of arguments[1] with a call to getArrayArgument() to find
	        the array data needed to process --->
		<cfset var argArray = getArrayArgument( arguments ) />
		<cfset var rate			= '' />
		<cfset var uom 			= '' />
		<cfset var prodCompId 	= '' />
		<cfset var scanVolume 	= '' />
		<cfset var rebateType 	= '' />
		<cfset var EAConversion 	= '' />
		<cfset var productInventoryUOM 	= '' />
		<cfset var Competitor_Price		= '' />
		<cfset var Competitor_Name_ID	= '' />
		<cfset var Competitor_Time_Frame	= '' />
		<cfset var CompetitorSourceOther	= '' />
		<!---D38536  :: Alternate recapture rates per component  START--->
		<cfset var ArratesCount= '' />
		<cfset var ArRates= '' />
		<cfset var ArUOM= ''/>
		<cfset var prodID='' />
		<cfset var CompNameID='' />
		<cfset var CompID='' />
		<!---D38536  :: Alternate recapture rates per component END --->
		<!---Competitor_Price Competitor_Name_ID Competitor_Time_Frame--->
		<!--- <cfset var source	 	= '' /> --->
		<cfset prodCompId 	= argArray[1][3] />
		<cfquery name="getProgID" datasource="#application.datasource#">
		 SELECT prc.Program_ID,prc.Program_Rebates_Component_ID
		 FROM Program_Rebates_Component_Data prcd
		 INNER JOIN Program_Rebates_Component prc
		 ON prcd.Program_Rebates_Component_ID = prc.Program_Rebates_Component_ID
		 WHERE prcd.Program_Rebates_Component_Data_ID = '#prodCompId#'
		</cfquery>

		<cfloop index="x" from="1" to="#arrayLen(argArray)#">
			<cfset rate			= argArray[x][1] />
			<cfset uom 			= argArray[x][2] />
			<cfset prodCompId 	= argArray[x][3] />
			<cfset scanVolume 	= argArray[x][6] />
			<cfset rebateType 	= argArray[x][7] />
			<cfset EAConversion	= argArray[x][8] />
			<cfset productInventoryUOM	= argArray[x][9] />
			<cfset Competitor_Name_ID	= argArray[x][10] />
			<cfset Competitor_Price		= argArray[x][11] />
			<cfset Competitor_Time_Frame = argArray[x][12] />
			<cfset CompetitorSourceOther = argArray[x][13] />
			<!---D38536  :: Alternate recapture rates per component  START--->
			<cfset ArratesCount	= argArray[x][14] />
			<cfset ArRates= argArray[x][15] />
			<cfset ArUOM= argArray[x][16] />
			<cfset ProdID= argArray[x][17] />
			<cfset CompNameID= argArray[x][18] />
			<cfset CompID=argArray[x][19] />
			<!---D38536  :: Alternate recapture rates per component  END--->
			<cfif trim(rate) eq ''>
				<cfset rate = 0 />
			</cfif>

			<!---
			for scan components if the uom selected by the user is "each", we store the rate entered by the user in the scan rate field
			and will store the rate converted to product UOM in the regular rate fields so that we do not have to change the rest of the application for now.
			once we have logic to handle uom="each" in other parts of the app we can remove the following conversion.

			if rebate type = Variable/Fixed Combo and uom=EA
			--->
			<cfset scanRate = rate />
			<cfset scanUom = uom />
			<cfif rebateType eq 4 and uom eq 5>
			 	<cfset uom = 1 />
				<cfif productInventoryUOM EQ "LB"><cfset uom = 2 /></cfif>
				<cfset rate = rate * EAConversion />
			</cfif>

			<!--- <cfset source	 	= argArray[x][4] /> --->
			<cfquery name="qUpdRebateProduct" datasource="#application.datasource#" result="qUpd">
				UPDATE	Program_Rebates_Component_Data
				SET		Rate = '#rate#',
						Unit_Of_Measure_ID = '#uom#'
						<cfif rebateType eq 4>
						,
						Scan_Rate = <cfqueryparam value="#scanRate#" cfsqltype="cf_sql_float" null="#scanRate EQ 0 OR IsNumeric(scanRate) EQ 0#">,
						scan_Uom =  <cfqueryparam value="#scanUom#" cfsqltype="cf_sql_integer" null="#scanRate EQ 0 OR IsNumeric(scanRate) EQ 0#">,
						Scan_Volume = <cfqueryparam value="#scanVolume#" cfsqltype="CF_SQL_DECIMAL" null="#scanVolume EQ 0 OR IsNumeric(scanVolume) EQ 0#">
						</cfif>
				OUTPUT INSERTED.Program_Rebates_Product_Data_ID
				WHERE	Program_Rebates_Component_Data_ID = '#prodCompId#'
			</cfquery>
			<!--- UPDATE  Program_Rebates_Product_Data LABEL D28445 --->
			<cfset this.updRebateProductData(	getProgID.Program_ID,
												qUpdRebateProduct.Program_Rebates_Product_Data_ID,
												Competitor_Price,
												Competitor_Name_ID,
												Competitor_Time_Frame,
												CompetitorSourceOther) />

<!---D38536  :: Alternate recapture rates per component START 	 --->
		<cfif ArratesCount>
					<cfset this.InsertAlternateRates(CompNameID,
																			#CompID#,
																			getProgID.Program_ID,
																			#ProdID#,
																			#ArRates#,
																			#ArUOM#,
																			#rate#,
																			#uom#
					) />
		</cfif>
<!---D38536  :: Alternate recapture rates per component END --->

		</cfloop>

		<cfset UpdStatus = UpdateGroupStatus('#getProgID.Program_ID#')>

		<cfreturn argArray />
	</cffunction>
	<!--- Used to display the page number links next to the save Button --->
	<cffunction Name="getPageLinks" access="public" output="false" returntype="string">
		<cfargument name="prodCount" type="numeric" required="true" default="0" />
		<cfargument name="svBtnAction" type="string" required="true" default="updSave" />
		<cfargument name="pageNum" type="numeric" required="true" default="1" />
		<cfset var retVar	= '' />
		<cfset var linkCount	= ceiling(prodCount/this.displayRecords) />
		<cfif linkCount LTE 1>
			<!--- only 1 page...no links needed --->
		<cfelse>
			<cfsavecontent variable="retVar">
				<cfoutput>
					<FONT COLOR="##FF0000"><B>[&nbsp;</B></FONT><FONT STYLE="COLOR:##0000FF;"><B>page&nbsp;</B></FONT>
					<cfloop from="1" to="#linkCount#" index="i">
						<SPAN ID="pageLink">
						<cfif i neq pageNum>
							<A HREF="##" onclick="setPageNum(#i#);submitForm('#arguments.svBtnAction#', 1, 'save_table');disableButton('pageLink','true'); return false;" STYLE="COLOR:##0000FF;" tabindex="#i#" title="Save Current Page and Go To Page #i#"><B>#i#&nbsp;</B></A>
						<cfelse>
							<SPAN title="Current Page is #i#" STYLE="COLOR:red;text-decoration : underline;"><i>#i#</i></SPAN>&nbsp;
						</cfif>
						</SPAN>
					</cfloop>
					<FONT COLOR="##FF0000"><B>]</B></FONT>
				</cfoutput>
			</cfsavecontent>
		</cfif>
		<cfreturn retVar />
	</cffunction>
	<!--- Used determine startRow for subset of products to display based on the current pageNum --->
	<cffunction Name="getStartRow" access="public" output="false" returntype="numeric">
		<cfargument name="pageNum" type="numeric" required="true" default="1" />
		<cfset var retVar		= ((pageNum * this.displayRecords) - this.displayRecords) + 1 />
		<cfreturn retVar />
	</cffunction>
	<!--- Used determine endRow for subset of products to display based on the current pageNum --->
	<cffunction Name="getEndRow" access="public" output="false" returntype="numeric">
		<cfargument name="pageNum" type="numeric" required="true" default="1" />
		<cfset var retVar		= (pageNum * this.displayRecords) />
		<cfreturn retVar />
	</cffunction>
	<!--- Dev Note: Milan; If the program has product groups, update the "Group_Processed" bit to 1. This gets called
		  while doing the following actions -
		  - adding groups, deleting groups (Click on scissors), saving rate (using the Save button),
		    adding component, deleting component
	--->
    <cffunction Name="UpdateGroupStatus" access="private" output="false">
	 <cfargument name="ProgramID" type="string" required="true" />

			<cfset useLakebaseForcheckGroupProgram = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForcheckGroupProgram>
	<cftry>
		<cfset checkGroupProgram = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"contract_main_id" = "eq.#arguments.ProgramID#",
				"is_group" = "eq.1",
				"deleted" = "eq.0",
				"select" = "contract_products_id"
			}), "contract_products_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheckGroupProgram = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheckGroupProgram>
<cfquery name="checkGroupProgram" datasource="#application.datasource#">
				SELECT Contract_Products_id
				FROM Contract_Products
				WHERE Contract_MAIN_ID = '#arguments.ProgramID#'
				AND Is_Group = 1
				AND Deleted = 0
			</cfquery>
</cfif>

			 <cfif checkGroupProgram.Recordcount GT 0>
				<cfquery name="qFlagGroup" datasource="#application.datasource#">
					UPDATE	Contract_Main
					SET		Group_Processed = 1
					WHERE	Deleted = 0
					AND 	Contract_Main_ID = '#arguments.ProgramID#'
				</cfquery>
			 </cfif>

	 </cffunction>
	<!--- Check whether the component and pProduct combo exists --->
	<cffunction Name="getComponentProductComboExist" access="public" output="true" returntype="query">
		<cfargument name="Program_ID" type="string" required="true" />
		<cfargument name="Product_ID" type="string" required="true" />
		<cfargument name="Program_Rebates_Component_Name_ID" type="numeric" required="true" />

			<cfquery name="qComponentProductComboExist" datasource="#application.datasource#">
				SELECT IsNull(program_Rebates_component_data.rate,0) As rate
				FROM program_Rebates_product_data
				INNER JOIN program_Rebates_component_data
				ON program_Rebates_product_data.Program_Rebates_product_data_ID = program_Rebates_component_data.program_Rebates_product_data_ID
				INNER JOIN program_Rebates_component
				ON program_Rebates_component_data.program_Rebates_component_ID = program_Rebates_component.program_Rebates_component_ID
				INNER JOIN contract_products
				ON contract_products.contract_products_ID = program_Rebates_product_data.contract_products_ID
				WHERE program_Rebates_product_data.program_ID = '#arguments.Program_ID#'
				AND program_Rebates_product_data.deleted = 0
				AND program_Rebates_component.deleted = 0
				AND program_Rebates_component_data.deleted = 0
				AND contract_products.deleted = 0
				AND contract_products.BSA_Foodservice_Items_Master_ID= '#arguments.Product_ID#'
				AND program_Rebates_component.Program_Rebates_Component_Name_ID = '#arguments.Program_Rebates_Component_Name_ID#'
			</cfquery>

		<cfreturn qComponentProductComboExist />
	</cffunction>

	<cffunction Name="getRebateProductComponentRate" access="public" output="true" returntype="query">
    <cfargument name="Program_ID" type="numeric" required="true" />
    <cfargument name="Product_ID" type="string" required="true" />
    <cfargument name="Component_Name_ID" type="numeric" required="true" />
    <cfargument name="Paid_To" type="numeric" required="true" />
      <cfif (arguments.Program_ID NEQ 0)>
			  <cfquery name="qryRebateProductComponentRate" datasource="#application.datasource#">
				  SELECT
            			IsNull(program_Rebates_component_data.rate,0) As Rate,
            			program_Rebates_component_data.Unit_Of_Measure_ID AS UOM
    				FROM program_Rebates_product_data
    				INNER JOIN program_Rebates_component_data
    				ON program_Rebates_product_data.Program_Rebates_product_data_ID = program_Rebates_component_data.program_Rebates_product_data_ID
    				INNER JOIN program_Rebates_component
    				ON program_Rebates_component_data.program_Rebates_component_ID = program_Rebates_component.program_Rebates_component_ID
    				INNER JOIN contract_products
    				ON contract_products.contract_products_ID = program_Rebates_product_data.contract_products_ID
    				WHERE program_Rebates_product_data.program_ID = '#arguments.Program_ID#'
    				AND program_Rebates_product_data.deleted = 0
    				AND program_Rebates_component.deleted = 0
    				AND program_Rebates_component_data.deleted = 0
    				AND contract_products.deleted = 0
    				AND contract_products.BSA_Foodservice_Items_Master_ID= '#arguments.Product_ID#'
    				AND program_Rebates_component.Program_Rebates_Component_Name_ID = '#arguments.Component_Name_ID#'
		<!--- Dev Note: drachala; D27521: HZPROD283  SARP PRG message . This value is greater than the template  START--->
     				-- AND program_Rebates_component.Component_Paid_To = '#arguments.Paid_To#'
			<!--- Dev Note: drachala; D27521: HZPROD283  SARP PRG message . This value is greater than the template  END--->
			</cfquery>
     </cfif>
     <cfif (arguments.Program_ID EQ 0) OR (qryRebateProductComponentRate.RecordCount EQ 0)>
        <cfset qryRebateProductComponentRate = QueryNew("Rate, UOM")>
        <cfset newRow  = QueryAddRow(qryRebateProductComponentRate, 1)>
        <cfset temp = QuerySetCell(qryRebateProductComponentRate, "Rate", "0", 1)>
        <cfset temp = QuerySetCell(qryRebateProductComponentRate, "UOM","0", 1)>
      </cfif>
      <cfreturn qryRebateProductComponentRate />
	</cffunction>

	<cffunction Name="getDataStructureComponentRate" access="private" output="false" returntype="struct">
    	<cfargument name="originalCompVal" type="array" required="true" />
    	<cfargument name="productID" type="string" required="true" />
		<cfargument name="compId" type="numeric" required="true" />
		<cfargument name="defaultRates" type="struct" required="true" />

		<cfset var stCompRate = Duplicate(defaultRates) />

		<cfset var iProdLen = ArrayLen(arguments.originalCompVal) />
		<cfloop from="1" to="#iProdLen#" index="iCounter">
			<cfif ArrayLen(arguments.originalCompVal[iCounter]) GTE compId>
				<cfif arguments.originalCompVal[iCounter][compId].prodID eq arguments.productID>
					<cfset stCompRate = arguments.originalCompVal[iCounter][compId] />
					<cfbreak>
				</cfif>
			</cfif>
		</cfloop>

      	<cfreturn stCompRate />
	</cffunction>

	<cffunction name="getfixedComponentType" >
		<cfargument name="programId" type="numeric" required="true" default="0">
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D28445 start--->
			<CFQUERY NAME="getFixedComponentInfo" datasource="#application.datasource#">
				SELECT	PFCN.Program_Fixed_Component_Name,
					PFCN.Program_Fixed_Component_Name_Id,
					PFCN.fixed_price_type
				FROM 	Program_Fixed_Component_Name PFCN
				INNER JOIN Program_Fixed_Component PFC ON
					PFC.Program_Fixed_Component_Name_ID = PFCN.Program_Fixed_Component_Name_ID
				WHERE 	PFCN.DELETED = 0 AND
						PFC.Program_ID = #arguments.programId# AND
						PFC.Deleted = 0 AND
						PFCN.fixed_price_type IN (1,3)
			</CFQUERY>
			<cfreturn getFixedComponentInfo.RecordCount />
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D28445 end--->
	</cffunction>

	<cffunction name="updRebateProductData" >
		<cfargument name="Program_ID" type="numeric" required="true" default="0">
		<cfargument name="Program_Rebates_Product_Data_ID" type="numeric" required="true" default="0">
		<cfargument name="Competitor_Price" type="string" required="true" default="0">
		<cfargument name="Competitor_Name_ID" type="any" required="true" default="0">
		<cfargument name="Competitor_Time_Frame" type="string" required="true" default="">
		<cfargument name="CompetitorSourceOther" type="string" required="true" default="">
		<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

			<cfif appsettings.getUseFixedPriceType() && isNumeric(Competitor_Name_ID) >  <!---&& this.getfixedComponentType(Program_ID) GT 0--->
				<cfif Competitor_Name_ID EQ -1>
					<!--- see if "other" record exists --->
					<cfset useLakebaseForgetOtherWonBy = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bid_won_by")>
<cfif useLakebaseForgetOtherWonBy>
	<cftry>
		<cfset getOtherWonBy = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_bid_won_by", {
				"program_bid_won_by_description" = "eq.#CompetitorSourceOther#",
				"program_bid_won_by_code" = "eq.#Program_ID#",
				"select" = "program_bid_won_by_description,program_bid_won_by_id"
			}), "program_bid_won_by_description,program_bid_won_by_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetOtherWonBy = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetOtherWonBy>
<cfquery name="getOtherWonBy" datasource="#application.datasource#">
						SELECT Program_Bid_Won_By_Description,
								Program_Bid_Won_By_ID
						FROM	Program_Bid_Won_By
						WHERE Program_Bid_Won_By_Description = '#CompetitorSourceOther#' AND
							Program_Bid_Won_By_Code = '#Program_ID#'
					</cfquery>
</cfif>
					<!--- Dont insert if it already exists --->
					<cfif getOtherWonBy.RecordCount>
						<cfset Competitor_Name_ID = getOtherWonBy.Program_Bid_Won_By_ID>
					<cfelse>
						<cfquery name="qInsertOther_Won_By" datasource="#application.datasource#">
							SET NOCOUNT ON
							INSERT INTO Program_Bid_Won_By
							(
								Program_Bid_Won_By_Code,
				            	Program_Bid_Won_By_Description,
				           		Active,
				            	Deleted,
				            	Updated_By
			            	)
							VALUES
							(
								#Program_ID#,
								'#CompetitorSourceOther#',
								0,
								0,
								'#request.AccessStructure.User_ID#'
							)
							SELECT Program_Bid_Won_By_ID = @@IDENTITY
							SET NOCOUNT OFF
						</cfquery>
						<cfset Competitor_Name_ID = qInsertOther_Won_By.Program_Bid_Won_By_ID>
					</cfif>
				</cfif>

				<cfquery name="qUpdRebateProductData" datasource="#application.datasource#">
					UPDATE	Program_Rebates_Product_Data
					SET <cfif Competitor_Price NEQ '' AND IsNumeric(Competitor_Price) >
							Competitor_Price = '#Competitor_Price#',
						<cfelse>
							Competitor_Price = null,
						</cfif>
						Competitor_Name_ID = '#Competitor_Name_ID#',
						Competitor_Time_Frame = '#Competitor_Time_Frame#'
					WHERE 	Program_Rebates_Product_Data_ID = '#Program_Rebates_Product_Data_ID#'
				</cfquery>
			</cfif>
	</cffunction>
<!---D38536  :: ALTERNATE RECAPTURE RATES PER COMPONENT START --->
	<cffunction name="InsertAlternateRates">
		<cfargument name="Component_Name_ID" 	type="numeric" 		required="true" 		default="0">
		<cfargument name="Component_ID" 		type="numeric" 		required="true" 		default="0">
		<cfargument name="Contract_Main_ID" 	type="numeric" 		required="true" 		default="0">
		<cfargument name="Contract_Product_ID" 	type="numeric" 		required="true" 		default="0">
		<cfargument name="Ar_rate" 				type="array" 		required="true" 		default="arraynew(1)">
		<cfargument name="Ar_uom" 				type="array" 		required="true" 		default="arraynew(1)">
		<cfargument name="rebRate"  			type="numeric" 		required="false" 		default="0"	>
		<cfargument name="rebUOM"  			type="numeric" 		required="false" 		default="0"	>



		<!--- FIGURING OUT ALTERNATE RATE INDEX --->
		<cfset useLakebaseForCheck_Alternate_Rate_Index = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("alternate_recapture_rate_setting")>
<cfif useLakebaseForCheck_Alternate_Rate_Index>
	<cftry>
		<cfset Check_Alternate_Rate_Index = application.oLakebase.toQuery(
			application.oLakebase.selectRows("alternate_recapture_rate_setting", {
				"program_rebates_component_name_id" = "eq.#arguments.component_name_id#",
				"order" = "alternate_recapture_rate_index.asc",
				"select" = "alternate_recapture_rate_index"
			}), "alternate_recapture_rate_index"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheck_Alternate_Rate_Index = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheck_Alternate_Rate_Index>
<cfquery name="Check_Alternate_Rate_Index" datasource="#application.datasource#">
			SELECT alternate_recapture_rate_index
			FROM alternate_recapture_rate_setting
			WHERE Program_Rebates_Component_Name_ID = #arguments.component_name_id#
			ORDER BY Alternate_Recapture_Rate_Index ASC
		</cfquery>
</cfif>

		<cfquery name="Check_Alternate_Rate_Index" datasource="#application.datasource#">
				<!---CHECK IF THERE ARE ANY EXISTING ALTERNATE RECAPTURE RATE RECORDS IF EXISIT DELETE THOSE RECORDS--->
				DELETE Program_Rebate_Alternate_Recapture_Rate
				WHERE Contract_Main_ID = <cfqueryparam value="#arguments.Contract_main_id#" cfsqltype="cf_sql_integer" />
				AND Contract_Products_ID =  <cfqueryparam value="#arguments.Contract_Product_ID#" cfsqltype="cf_sql_integer" />
				AND Program_Rebates_Component_ID =  <cfqueryparam value="#arguments.Component_ID#" cfsqltype="cf_sql_integer" />
			<cfloop query="Check_Alternate_Rate_Index">
			<cfif #Ar_rate[Check_Alternate_Rate_Index.Currentrow]# GT rebRate><cfset Ar_rate[Check_Alternate_Rate_Index.Currentrow] = arguments.rebRate> </cfif>
                		INSERT INTO Program_Rebate_Alternate_Recapture_Rate
						VALUES (
										#arguments.Component_ID#,
										#arguments.Contract_main_id#,
										#arguments.Contract_Product_ID#,
										#alternate_recapture_rate_index#,
										#Ar_rate[Check_Alternate_Rate_Index.Currentrow]#,
										#Ar_uom[Check_Alternate_Rate_Index.Currentrow]#
						)

			</cfloop>
	</cfquery>
		<cfquery name="Log_Alternate_Rate" datasource="#application.datasource#">
				INSERT INTO Program_Rebate_Alternate_Recapture_Rate_History (Program_Rebate_Alternate_Recapture_Rate_ID,Program_Rebates_Component_ID,Contract_Main_ID,Contract_Products_ID,Alternate_Recapture_Rate_Index,Rate,UOM)
				SELECT Program_Rebate_Alternate_Recapture_Rate_ID,Program_Rebates_Component_ID,Contract_Main_ID,Contract_Products_ID,Alternate_Recapture_Rate_Index,Rate,UOM
				FROM Program_Rebate_Alternate_Recapture_Rate
				WHERE Program_Rebates_Component_ID = <cfqueryparam value="#arguments.Component_ID#" cfsqltype="cf_sql_integer" />
				AND Contract_Main_ID = <cfqueryparam value="#arguments.contract_main_id#" cfsqltype="cf_sql_integer" />
				AND Contract_Products_ID =  <cfqueryparam value="#arguments.Contract_Product_ID#" cfsqltype="cf_sql_integer" />
		</cfquery>
	</cffunction>

<!---D38536  :: ALTERNATE RECAPTURE RATES PER COMPONENT END --->
<!--- D38846 ::  Recapture changes START--->
	<cffunction name="InsertMassApplyAlternateRates" output="true">
		<cfargument name="stDataStructure" 	type="struct" 	required="false" 	default="" />
		<cfargument name="ThisForm"					type="any" 		required="false" 	default="" />

		<!--- Scan thru all products:
		  1. Look for products that are checked
		  2. Scan thru all components:
		       2a. Scan thru all alternate recapture columns
		       2b. Look for alternate recapture columns that are checked
		       2c. Update database

		  Note: form element names with GUID values (e.g. product ID) have all dashes replaced with underscores:
		        Example: form.prodChkBx_e146f56f_b3c5_46f2_9fbb_5f0c7bac493b
		--->
		<cfloop array="#arguments.stDataStructure.aProd#" index="local.Product">
			<!--- 1. is this product checked by the user? form.prodChkBx_e146f56f_b3c5_46f2_9fbb_5f0c7bac493b (all dashes are replaced with underscores) --->
			<cfif StructKeyExists( arguments.ThisForm, "prodChkBx_" & request.app_general_functions.replaceHyphen(local.Product.MasterItemID) )>
				<!--- 2. scan thru all components --->
				<cfloop array="#arguments.stDataStructure.aComp#" index="local.Component">
					<!--- 2a. scan thru all alternate recapture rate within a component --->
					<cfloop from="1" to="#local.Component.alternate_recapture_rate#" index="local.alternate_recapture_index">
						<!--- 2b. is this alternate recapture box checked? form.AR_MassApply_23_1 --->
						<cfif StructKeyExists( arguments.ThisForm, "AR_MassApply_" & local.Component.CompNameID & '_' & local.alternate_recapture_index )>
							<!--- 2c. update database --->
							<!--- if mass apply rate is blank use the old rate --->
							<cfif len(arguments.thisForm.apply_rate)>
								<cfset local.rate = arguments.thisForm.apply_rate>
							<cfelse>
								<cfset local.rate = arguments.ThisForm[ 'ARR_' & local.alternate_recapture_index & '_' & request.app_general_functions.replaceHyphen(local.Product.MasterItemID) & '_' & local.Component.CompID ]>
							</cfif>

							<cfquery name="local.qUpdate" datasource="#application.datasource#">
								DELETE Program_Rebate_Alternate_Recapture_Rate
		 						 WHERE Contract_Main_ID                    = <cfqueryparam value="#local.Component.programID#" cfsqltype="cf_sql_integer" />
												AND Program_Rebates_Component_ID   = <cfqueryparam value="#local.Component.compuuID#" cfsqltype="cf_sql_integer" />
												AND Contract_Products_ID           = <cfqueryparam value="#local.Product.ContractProdID#" cfsqltype="cf_sql_integer" />
												AND Alternate_Recapture_Rate_Index = <cfqueryparam value="#local.alternate_recapture_index#" cfsqltype="cf_sql_integer" />

								INSERT INTO Program_Rebate_Alternate_Recapture_Rate
												(   Program_Rebates_Component_ID
										      , Contract_Main_ID
										      , Contract_Products_ID
										      , Alternate_Recapture_Rate_Index
										      , Rate
										      , UOM
												)
								 VALUES (   <cfqueryparam value="#local.Component.compuuID#" cfsqltype="cf_sql_integer" />
													, <cfqueryparam value="#local.Component.programID#" cfsqltype="cf_sql_integer" />
													, <cfqueryparam value="#local.Product.ContractProdID#" cfsqltype="cf_sql_integer" />
													, <cfqueryparam value="#local.alternate_recapture_index#" cfsqltype="cf_sql_integer" />
													, #local.rate#
													, #arguments.thisForm.apply_uom#
												)

								INSERT INTO Program_Rebate_Alternate_Recapture_Rate_History
												(	Program_Rebate_Alternate_Recapture_Rate_ID,
													Program_Rebates_Component_ID,
													Contract_Main_ID,
													Contract_Products_ID,
													Alternate_Recapture_Rate_Index,
													Rate,
													UOM
												)
										SELECT Program_Rebate_Alternate_Recapture_Rate_ID,
												Program_Rebates_Component_ID,
												Contract_Main_ID,
												Contract_Products_ID,
												Alternate_Recapture_Rate_Index,
												Rate,
												UOM
										 FROM Program_Rebate_Alternate_Recapture_Rate
												WHERE Program_Rebates_Component_ID       = <cfqueryparam value="#local.Component.compuuID#" cfsqltype="cf_sql_integer" />
															AND Contract_Main_ID               = <cfqueryparam value="#local.Component.programID#" cfsqltype="cf_sql_integer" />
															AND Contract_Products_ID           = <cfqueryparam value="#local.Product.ContractProdID#" cfsqltype="cf_sql_integer" />
															AND Alternate_Recapture_Rate_Index = <cfqueryparam value="#local.alternate_recapture_index#" cfsqltype="cf_sql_integer" />
							</cfquery>
						</cfif>  <!--- StructKeyExists( arguments.ThisForm, "AR_MassApply_" & local.aComponent.CompNameID & local.alternate_recapture_index ) --->
					</cfloop>  <!--- from="1" to="#local.Component.alternate_recapture_rate#" index="local.alternate_recapture_index" --->
				</cfloop>  <!--- array="#arguments.stDataStructure.aComp#" index="local.Component" --->
			</cfif>  <!--- StructKeyExists(arguments.ThisForm, "prodChkBx_" & local.Product.MasterItemID --->
		</cfloop>  <!--- array="#arguments.stDataStructure.aProd#" index="local.Product" --->

	</cffunction>

<!--- D38846 ::  Recapture changes END--->
<cffunction name="dmp" >
		<cfargument name="x" type="any" required="true" default="">
		<!---<cfdump var="#x#" output="c:\dump.log">--->
	</cffunction>

<!--- D44174	Prod Event 643 - Routines cannot be declared more than once. The routine getBrandName has been declared twice in different templates START--->
	<cffunction name="getBrandName" output="true" returntype="string">
		<cfargument name="item_master_id"	required="true">
		<cfargument name="Brand_Query"	required="true" type="Query"  >
		<!--- gather brand information for a single item --->
		<cfquery name="local.qoqBrand" dbtype="query">
			SELECT Brand_Name
			  FROM arguments.Brand_Query
			 WHERE BSA_Foodservice_Items_Master_ID = <cfoutput>'#arguments.item_master_id#'</cfoutput>
		</cfquery>
	
		<cfreturn local.qoqBrand.Brand_Name>
	</cffunction>
<!--- D44174	Prod Event 643 - Routines cannot be declared more than once. The routine getBrandName has been declared twice in different templates END--->

</cfcomponent>