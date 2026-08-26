<!---
	Description:
		Base component for a program rebate

--->

<cfcomponent displayname="Rebate" hint="Component used to handle program component rebates." >

	<cfproperty name="tmpFilePath" type="string" hint="A path to the file holding the WDDX data structure.">

	<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
	<cfset this.GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />
	<cfset objPrgManager = CreateObject("component","components.programs.ProgramManager") />
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
				"select" = "first_parent_id,single_component_per_discount_type,ratetypedefault"
			}), "first_parent_id,single_component_per_discount_type,ratetypedefault"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetTemplateInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetTemplateInfo>
<cfquery name="GetTemplateInfo" datasource="#application.datasource#">
			SELECT First_parent_ID,
			Single_Component_Per_Discount_Type,
			rateTypeDefault
			FROM Program_Control_Panel_Options
			WHERE ProgramControl_Panel_Options_ID = '#GetContractInfo.ProgramType_ID#'
		</cfquery>
</cfif>

<!--- 96178 START--->
<cfquery name="variables.drop_tempdb" datasource="#application.datasource#">
	IF OBJECT_ID('tempdb..##tmpAltRate') IS NOT NULL
	DROP TABLE ##tmpAltRate

	IF OBJECT_ID('tempdb..##tmpAProd') IS NOT NULL
	DROP TABLE ##tmpAProd
</cfquery>

<cfquery name="variables.create_tempdb" datasource="#application.datasource#">
	CREATE TABLE ##tmpAProd (
		ItemId uniqueidentifier,
		Item varchar(200),
		groupNumber varchar(200),
		ItemDesc varchar(200),
		arIndex int identity)
</cfquery>
 <!--- 96178 END--->

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
					FROM 	 Program_Control_Panel_Options
					WHERE	ProgramControl_Panel_Options_ID = #arguments.template_id#
				</cfquery>
</cfif>
		<cfset bDiscountRebateMaxRateOn = qGettemplatesettings.Discount_Rebate_Max_Rate_On />

		 <!---	<cfif (isDefined("arguments.RevisionOfExistingContract") AND arguments.RevisionOfExistingContract EQ 1)>
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

			<!--- GeneralSettingsManager =	CreateObject("component", "components.settings.ApplicationSettingsManager").init().get(); --->
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
							---62343 START
							<cfif appSettings.get_Setting('Blended_Rate') eq '1'>
							,Program_Rebates_Component.Calculation_Period_Start
							,Program_Rebates_Component.Calculation_Period_End
							,CASE WHEN Program_Rebates_Component_Name.Rebate_Type = 7 THEN 1 ELSE 0 END AS Blended_Rate_On
							</cfif>
							---62343 END
							---65711 START
							,Program_Rebates_Component.component_Default_rate
							,Program_Rebates_Component.component_Default_uom
							--65711 END
					FROM 	Program_Rebates_Component
					INNER JOIN Program_Rebates_Component as Program_Rebates_Component_EZ_Original_Program
					ON			Program_Rebates_Component_EZ_Original_Program.Deleted = 0
					AND		Program_Rebates_Component_EZ_Original_Program.Program_ID = #arguments.EZOriginalProgramID#
					AND		Program_Rebates_Component_EZ_Original_Program.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID
					<cfif appSettings.getPaymentCycleAtDiscountType()>
						LEFT JOIN Program_Payment_Cycle
						ON Program_Payment_Cycle.Discount_Type_ID = 2
						AND Program_Payment_Cycle.Program_ID = Program_Rebates_Component_EZ_Original_Program.Program_ID
						AND Program_Payment_Cycle.Component_ID = Program_Rebates_Component_EZ_Original_Program.Program_Rebates_Component_ID
						AND Program_Payment_Cycle.Deleted = 0
					</cfif>
					<cfif appSettings.get_Setting('Blended_Rate') eq '1'>
						<!---
						1)	When we create a dummy program in EZ button setting page we are saving a dummy record in Program rebate component table with ID 0.
						So dont't modified LEft join to Inner join which will cause issues in EZ button set up page.
					---->
					LEFT JOIN Program_Rebates_Component_Name
					ON Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID
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
							<!---62343 8.0 - Blended Rate, CF START--->
							<cfif appSettings.get_Setting('Blended_Rate') eq '1'>
							,PRC.Calculation_Period_Start
							,PRC.Calculation_Period_End
							,CASE WHEN Program_Rebates_Component_Name.Rebate_Type = 7 THEN 1 ELSE 0 END AS Blended_Rate_On
							</cfif>
							<!---62343 8.0 - Blended Rate, CF END--->
							---65711 START
							,PRC.component_Default_rate
							,PRC.component_Default_uom
							,ISNULL(Program_Rebates_Component_Name.Include_Second_Component, 0) AS Include_Second_Component
							,ISNULL(Program_Rebates_Component_Name.Second_Component_Name_ID, 0) AS Second_Component_Name_ID
							,PRC.Dont_Count_Volume
							--65711 END
					FROM 	Program_Rebates_Component PRC
					<cfif appSettings.getPaymentCycleAtDiscountType()>
						LEFT JOIN Program_Payment_Cycle
						ON Program_Payment_Cycle.Discount_Type_ID = 2
						AND Program_Payment_Cycle.Program_ID = PRC.Program_ID
						AND Program_Payment_Cycle.Component_ID = PRC.Program_Rebates_Component_ID
						AND Program_Payment_Cycle.Deleted = 0
					</cfif>
					LEFT JOIN Program_Rebates_Component_Profile PRCP
					ON PRCP.Program_Rebates_Component_Name_ID = PRC.Program_Rebates_Component_Name_ID
					AND PRCP.Profiles_ID = #request.AccessStructure.Profiles_ID#
					AND PRCP.Deleted = 0
					<!---
						1)	When we create a dummy program in EZ button setting page we are saving a dummy record in Program rebate component table with ID 0.
						So dont't modified LEft join to Inner join which will cause issues in EZ button set up page.
					---->
					LEFT JOIN Program_Rebates_Component_Name
					ON Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = PRC.Program_Rebates_Component_Name_ID
					<cfif IsDateExclusion eq 0>
					WHERE 	PRC.Program_ID = #arguments.programID#
					<cfelse>
					WHERE 	PRC.Program_ID IN (#arguments.programID#)
					</cfif>
					AND PRC.Deleted = 0
					AND (PRCP.Program_Rebates_Component_Profile_ID IS NULL OR PRCP.Allow_User_To_View = 1)
					ORDER BY PRC.Program_Rebates_Component_ID
				</cfquery>
			</cfif>

			<cfquery name="variables.drop_tempdb" datasource="#application.datasource#">   <!--- 61108 --->
				IF OBJECT_ID('tempdb..##tmp_rebate_rates') IS NOT NULL
		 		DROP TABLE ##tmp_rebate_rates
				IF OBJECT_ID('tempdb..##tmp_all_results') IS NOT NULL
		 		DROP TABLE ##tmp_all_results
		 	</cfquery>


			<cfquery name="qGetProds" datasource="#application.datasource#">
				DECLARE
				@AppSetting_Percentage_Of_List_Price BIT,
				@Tmplt_Percentage_Of_List_Price BIT,
				@Price_List_ID NVARCHAR(50)

				SELECT @AppSetting_Percentage_Of_List_Price = value FROM _Settings WHERE Input_name='Percentage_Of_List_Price'

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
				AND	Contract_Products.Captured_From_Group = 0
		</cfif>
				SELECT 	DISTINCT
						<cfif IsDateExclusion eq 0>
							<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getUseProductHierarchy()>
								/* Product_Hierarchy.Product_Hierarchy, */
								CAST('' as varchar(50)) as Product_Hierarchy,
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
						ISNULL(Contract_Products.Pricing_Level_ID, 1)  AS Pricing_Level_ID,
						Contract_Products.Is_Group,
						All_Product_Group_Types.Group_Number,
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
						BSA_Foodservice_Items_Master.Item,
						BSA_Foodservice_Items_Master.UPC,
						BSA_Foodservice_Items_Master.Description,
						BSA_Foodservice_Items_Master.Inventory_UM,
						BSA_Foodservice_Items_Master.net_weight,
						BSA_Foodservice_Items_Master.Type_Code_Desc_ID,
						BSA_Foodservice_Items_Master.Product_Hierarchy_id,
						ISNULL(BSA_Foodservice_Items_Master.Case_Count, 1) as EA_Conversion,
						CASE
							WHEN ISNULL(BSA_Foodservice_Items_Master.Sleeves_Per_Case, 0) = 0 THEN 1
							ELSE ISNULL(BSA_Foodservice_Items_Master.Sleeves_Per_Case, 1) end as Sleeves_Per_Case,
						BSA_Foodservice_Items_Master.Pack_Size,
						BSA_Foodservice_Items_Master.Pack_Size_UOM,
						Contract_Main.Contract_Start_Date,
						Contract_Main.Contract_End_Date,
						Contract_Main.IsExclusionRevision,
						PRCD.Program_Rebates_Component_ID,
						/* ---xxxxxxxx */

						CASE
							WHEN isnull(PRCD.Unit_Of_Measure_ID,1) = 1 THEN Cast(isnull(nullif(PRCD.Rate,''),0) as decimal(20,#appSettings.get_Setting('Decimal_display_for_CS')#))
							WHEN isnull(PRCD.Unit_Of_Measure_ID,1) = 2 THEN Cast(isnull(nullif(PRCD.Rate,''),0) as decimal(20,#appSettings.get_Setting('Decimal_display_for_LB')#))
							WHEN isnull(PRCD.Unit_Of_Measure_ID,1) = 3 THEN Cast(isnull(nullif(PRCD.Rate,''),0) as decimal(20,#appSettings.get_Setting('Decimal_display_for_Percentage')#))
							WHEN isnull(PRCD.Unit_Of_Measure_ID,1) = 5 THEN Cast(isnull(nullif(PRCD.Rate,''),0) as decimal(20,#appSettings.get_Setting('Decimal_display_for_EA')#))
							WHEN isnull(PRCD.Unit_Of_Measure_ID,1) = 6 THEN Cast(isnull(nullif(PRCD.Rate,''),0) as decimal(20,#appSettings.get_Setting('Decimal_display_for_CWT')#))
						 END As reb_Rate,

						Cast(isnull(nullif(PRCD.Ez_Contract_Max_Rate,''),0) as decimal(10,4)) As Ez_Contract_Max_Rate_DB,
						isnull(PRCD.Unit_Of_Measure_ID,1) AS Unit_Of_Measure_ID,
						isnull(PRCD.User_Picked_UOM,0) AS User_Picked_UOM,<!---63887 --->
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
						Contract_Products.Base_Sales_CS, <!--- D30357:Today's Price Wrong on Revision History --->
						PCPO.Percentage_Of_List_Price,
						PCPO.Price_List_ID,
						CAST(0 as float) as Price_CS_DEL,
						CAST(0 as float) as Price_CS_FOB,
						CAST(0 as float) as Price_LB_DEL,
						CAST(0 as float) as Price_LB_FOB
						<!---62343 8.0 - Blended Rate, CF START--->
						,ISNULL(PRCD.Blended_Base_Rate, 0) AS Blended_Base_Rate
						,ISNULL(PRCD.Blended_Disc_Rate, 0) AS Blended_Disc_Rate
						,ISNULL(PRCD.Blended_Calc_Rate, 0) AS Blended_Calc_Rate
						,PRCD.Blended_Adj_Rate AS Blended_Adj_Rate
						<!---62343 8.0 - Blended Rate, CF END--->

				INTO	##tmp_rebate_rates
				FROM 	Program_Rebates_Product_Data PRPD
						INNER JOIN Contract_Products
						ON Contract_products.contract_main_id = #arguments.programID#
						AND	Contract_Products.Contract_Products_ID = PRPD.Contract_Products_ID
						AND Contract_Products.Deleted = 0
						AND Contract_Products.Captured_From_Group = 0
						<cfif arguments.contractProdId gt 0>
						AND 	Contract_Products.Contract_Products_Id = #arguments.contractProdId#
						</cfif>
						LEFT JOIN 	Program_Rebates_Component_Data PRCD
						ON	PRCD.Program_Rebates_Product_Data_ID = PRPD.Program_Rebates_Product_Data_ID
						AND PRCD.Deleted = 0
						LEFT JOIN 	Program_Rebates_Component
						ON	Program_Rebates_Component.Program_Rebates_Component_ID = PRCD.Program_Rebates_Component_ID
						AND Program_Rebates_Component.Deleted = 0
						LEFT JOIN Program_Rebates_Component_Profile PRCP
						ON PRCP.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID
						AND PRCP.Profiles_ID = #request.AccessStructure.Profiles_ID#
						AND PRCP.Deleted = 0
						INNER JOIN BSA_Foodservice_Items_Master
						ON	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
						<cfif arguments.itemMasterId neq "0">
						AND 	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = '#arguments.itemMasterId#'
						</cfif>
						<!--- Tim Ford WR 49860 - User not able to click on the REBATE link inside programs from the OP1 and OP4 templates
						This join was causing performance issues. Moving this logic below in an update statement.
						<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getUseProductHierarchy()>
						LEFT JOIN Product_Hierarchy ON
						((Contract_Products.BSA_Foodservice_Items_Master_ID = Product_Hierarchy.Product_Hierarchy_id AND Contract_Products.Is_Group = 1)
						OR (BSA_Foodservice_Items_Master.Product_Hierarchy_id =Product_Hierarchy.Product_Hierarchy_id	AND Contract_Products.Is_Group = 0)
						)
						</cfif>
						--->
						INNER JOIN Contract_Main
						ON Contract_Main.Contract_Main_ID =	#arguments.programID#
						INNER JOIN Program_Control_Panel_Options PCPO
						ON PCPO.ProgramControl_Panel_Options_ID = Contract_Main.programtype_id

						<cfif arguments.checktemplatesettings EQ 1 and arguments.groupfieldname IS NOT "">
							<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
							<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo(application.oApplicationAppSettingsManager.getApplicationAppSettings().getTemplateRestrictGroupLevel()) />

							INNER JOIN Template_Allow_Approval_Group
							ON Template_Allow_Approval_Group.Group_ID =
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
				<cfif qGettemplatesettings.Discount_Rebates_Item_Level EQ 1 and	qGettemplatesettings.Discount_Rebates_Group_Level EQ 0>
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
		 <!---	-- Added for bringing only the products that are in the above component to be copied.
			-- 21553: HZ - min/max rates for EZ button/Anand Rao/ 15-Mar-10
			-- AND Program_Rebates_Component.Program_Rebates_Component_ID IN (#ValueList(qGetComps.Program_Rebates_Component_ID)#)	--->
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

		<!---- Update price --->
		UPDATE	t
		SET		Price_CS_DEL = ISNULL(CAST(Price_List_Detail.CS_Bracket_1 as float),0),
				Price_CS_FOB = ISNULL(CAST(Price_List_Detail.CS_FOB_Price as float),0),
				Price_LB_DEL = (ISNULL(CAST(Price_List_Detail.CS_Bracket_1 as float),0) / Net_Weight),
				Price_LB_FOB = (ISNULL(CAST(Price_List_Detail.CS_FOB_Price as float),0) / Net_Weight)
		FROM	##tmp_rebate_rates t
		INNER JOIN Price_List_Header
		ON Price_List_Header.Price_List_ID = t.Price_List_ID
		INNER JOIN Price_List_Detail
		ON	Price_List_Header.Price_List_Header_ID = Price_List_Detail.Price_List_Header_ID
		AND Price_List_Detail.Product_ID = t.BSA_Foodservice_Items_Master_ID
		AND Price_List_Detail.Active_Code = 'A'
		AND t.Contract_Start_Date BETWEEN Price_List_Detail.Start_Date and Price_List_Detail.End_Date

		<!--- Tim Ford WR 49860 - User not able to click on the REBATE link inside programs from the OP1 and OP4 templates --->
		<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getUseProductHierarchy()>
		UPDATE	##tmp_rebate_rates
		SET		Product_Hierarchy = Product_Hierarchy.Product_Hierarchy
		FROM	##tmp_rebate_rates
		INNER JOIN Product_Hierarchy
		ON		(##tmp_rebate_rates.BSA_Foodservice_Items_Master_ID = Product_Hierarchy.Product_Hierarchy_id AND ##tmp_rebate_rates.Is_Group = 1)

		UPDATE	##tmp_rebate_rates
		SET		Product_Hierarchy = Product_Hierarchy.Product_Hierarchy
		FROM	##tmp_rebate_rates
		INNER JOIN Product_Hierarchy
		ON	(##tmp_rebate_rates.Product_Hierarchy_id = Product_Hierarchy.Product_Hierarchy_id	AND ##tmp_rebate_rates.Is_Group = 0)
		</cfif>

		SELECT	IDENTITY(INT,1,1) AS Row_Number, *,
		<cfif bDiscountRebateMaxRateOn eq 1><!--- arguments.EZOriginalProgramID was used earlier --->
		CASE WHEN Ez_Contract_Max_Rate_DB = 0 THEN
			reb_Rate
		ELSE
			Ez_Contract_Max_Rate_DB
		END as Ez_Contract_Max_Rate
		<cfelse>
			Ez_Contract_Max_Rate_DB AS Ez_Contract_Max_Rate
		</cfif>
		INTO ##tmp_all_results
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

	INSERT INTO ##tmpAProd( ItemId, Item,  groupNumber, ItemDesc)
	SELECT BSA_Foodservice_Items_Master_ID, Item, Group_Number, Description
	FROM ##tmp_all_results
	GROUP BY BSA_Foodservice_Items_Master_ID, Item, Group_Number, Description
	ORDER BY Min(Row_Number)

	SELECT * FROM ##tmp_all_results ORDER BY Row_Number

	DROP TABLE ##tmp_all_results
	DROP TABLE ##tmp_rebate_rates

			<cfif arguments.EZOriginalProgramID neq 0><!--- copy of ez button program --->
			DROP TABLE ##Tmp_Program_Product_EZ_Original_Program
			</cfif>
		</cfquery>

				<!--- START: 25709: EZ Button/Anand Rao/25-Mar-2011 --->
<cfif (isdefined("arguments.template_id") and arguments.template_id NEQ 0 AND qGetProds.RecordCount EQ 0 AND	arguments.EZButton_On EQ 1 AND qGetTemplateSettings.EzButton_Default_Show_Item_Rates EQ 1)>
<!--- If the above query returns RecordCount of 0 then that means program is just being created or is in edit mode but no products added. So in both these cases we will display the items and rates in the template	 --->

		<cfquery name="qGetProds" datasource="#application.datasource#">
			DECLARE
			@AppSetting_Percentage_Of_List_Price BIT,
			@Tmplt_Percentage_Of_List_Price BIT,
			@Price_List_ID NVARCHAR(50)

			SELECT @AppSetting_Percentage_Of_List_Price = value FROM _Settings WHERE Input_name='Percentage_Of_List_Price'

				IF OBJECT_ID('tempdb..##tmp_rebate_rates') IS NOT NULL
		DROP TABLE ##tmp_rebate_rates
		IF OBJECT_ID('tempdb..##tmp_all_results') IS NOT NULL
		DROP TABLE ##tmp_all_results

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
						ISNULL(BSA_Foodservice_Items_Master.Case_Count, 1) as EA_Conversion,
						CASE
							WHEN ISNULL(BSA_Foodservice_Items_Master.Sleeves_Per_Case, 0) = 0 THEN 1
							ELSE ISNULL(BSA_Foodservice_Items_Master.Sleeves_Per_Case, 1) end as Sleeves_Per_Case,
						BSA_Foodservice_Items_Master.Pack_Size,
						BSA_Foodservice_Items_Master.Pack_Size_UOM,
						Contract_Main.Contract_Start_Date,
						Contract_Main.Contract_End_Date,
						Contract_Main.IsExclusionRevision,
						PRCD.Program_Rebates_Component_ID,
						---xxxxxxxx
						Cast(isnull(nullif(PRCD.Rate,''),0) as decimal(18,4)) As reb_Rate,
						Cast(isnull(nullif(PRCD.Ez_Contract_Max_Rate,''),0) as decimal(18,4)) As Ez_Contract_Max_Rate_DB,
						isnull(PRCD.Unit_Of_Measure_ID,1) AS Unit_Of_Measure_ID,
						isnull(PRCD.User_Picked_UOM,0) AS User_Picked_UOM,<!---63887 --->
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
						Contract_Products.Base_Sales_CS, <!--- D30357:Today's Price Wrong on Revision History --->
						PCPO.Percentage_Of_List_Price,
						PCPO.Price_List_ID,
						CAST(0 as float) as Price_CS_DEL,
						CAST(0 as float) as Price_CS_FOB,
						CAST(0 as float) as Price_LB_DEL,
						CAST(0 as float) as Price_LB_FOB
						<!---62343 8.0 - Blended Rate, CF START--->
						,ISNULL(PRCD.Blended_Base_Rate, 0) AS Blended_Base_Rate
						,ISNULL(PRCD.Blended_Disc_Rate, 0) AS Blended_Disc_Rate
						,ISNULL(PRCD.Blended_Calc_Rate, 0) AS Blended_Calc_Rate
						,PRCD.Blended_Adj_Rate  AS Blended_Adj_Rate
						<!---62343 8.0 - Blended Rate, CF END--->
			into	##tmp_rebate_rates
				FROM 	Program_Rebates_Product_Data PRPD
						INNER JOIN Contract_Products ON
						Contract_products.contract_main_id = #arguments.programID# AND
						Contract_Products.Contract_Products_ID = PRPD.Contract_Products_ID
						AND Contract_Products.Deleted = 0

						AND Contract_Products.Captured_From_Group = 0
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

							(BSA_Foodservice_Items_Master.Product_Hierarchy_id =Product_Hierarchy.Product_Hierarchy_id	AND Contract_Products.Is_Group = 0)
						)
						</cfif>
						INNER JOIN Contract_Main
						ON Contract_Main.Contract_Main_ID =	#arguments.programID#
						INNER JOIN Program_Control_Panel_Options PCPO on PCPO.ProgramControl_Panel_Options_ID = Contract_Main.programtype_id

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
				<cfif qGettemplatesettings.Discount_Rebates_Item_Level EQ 1 and	qGettemplatesettings.Discount_Rebates_Group_Level EQ 0>
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
		 <!---	-- Added for bringing only the products that are in the above component to be copied.
			-- 21553: HZ - min/max rates for EZ button/Anand Rao/ 15-Mar-10
			-- AND Program_Rebates_Component.Program_Rebates_Component_ID IN (#ValueList(qGetComps.Program_Rebates_Component_ID)#)	--->
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
		<!---- Update price --->
		UPDATE	t
		SET		Price_CS_DEL = ISNULL(CAST(Price_List_Detail.CS_Bracket_1 as float),0),
				Price_CS_FOB = ISNULL(CAST(Price_List_Detail.CS_FOB_Price as float),0),
				Price_LB_DEL = (ISNULL(CAST(Price_List_Detail.CS_Bracket_1 as float),0) / Net_Weight),
				Price_LB_FOB = (ISNULL(CAST(Price_List_Detail.CS_FOB_Price as float),0) / Net_Weight)
		FROM	##tmp_rebate_rates t
		INNER JOIN Price_List_Header
		ON Price_List_Header.Price_List_ID = t.Price_List_ID
		INNER JOIN Price_List_Detail
		ON	Price_List_Header.Price_List_Header_ID = Price_List_Detail.Price_List_Header_ID
		AND Price_List_Detail.Product_ID = t.BSA_Foodservice_Items_Master_ID
		AND Price_List_Detail.Active_Code = 'A'
		AND t.Contract_Start_Date BETWEEN Price_List_Detail.Start_Date and Price_List_Detail.End_Date

		SELECT	IDENTITY(INT,1,1) AS Row_Number, *,
		<cfif bDiscountRebateMaxRateOn eq 1><!--- arguments.EZOriginalProgramID was used earlier --->
		CASE WHEN Ez_Contract_Max_Rate_DB = 0 THEN
			reb_Rate
		ELSE
			Ez_Contract_Max_Rate_DB
		END as Ez_Contract_Max_Rate
		<cfelse>
			Ez_Contract_Max_Rate_DB AS Ez_Contract_Max_Rate
		</cfif>
		INTO ##tmp_all_results
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

		INSERT INTO ##tmpAProd( ItemId, Item,  groupNumber, ItemDesc)
		SELECT BSA_Foodservice_Items_Master_ID, Item, Group_Number, Description
		FROM ##tmp_all_results
		GROUP BY BSA_Foodservice_Items_Master_ID, Item, Group_Number, Description
		ORDER BY Min(Row_Number)

		SELECT * FROM ##tmp_all_results

		DROP TABLE ##tmp_all_results
		DROP TABLE ##tmp_rebate_rates
		<cfif arguments.EZOriginalProgramID neq 0><!--- copy of ez button program --->
		DROP TABLE ##Tmp_Program_Product_EZ_Original_Program
		</cfif>
	</cfquery>

</cfif>
			<!--- Dev Note - (79237)  Find the 2nd Component (Child of the first component). IF there are multiple components with
			a second component, then there will be more than one second component.
			--->
			<cfset local.SecondComponentList = "">
			<cfloop query="qGetComps">
				<cfif Include_Second_Component eq 1>
					<cfset local.SecondComponentList = ListAppend(local.SecondComponentList,Second_Component_Name_ID)>
				</cfif>
			</cfloop>
				<!--- END: 25709: EZ Button/Anand Rao/25-Mar-2011 --->
			<cfloop query="qGetComps">
				<cfset local.IsSecondComponent= 0>
			<!--- Dev Note - (79237) Find out whether this is a 2nd Component (Child of the first component) --->
				<cfif ListFind(local.SecondComponentList,Program_Rebates_Component_Name_ID) neq 0>
					<cfset local.IsSecondComponent = 1>
				</cfif>

				<!--- D38536	:: Alternate recapture rates per component START--->
					<cfquery name="ARSettings" datasource="#application.datasource#">
						SELECT *
						FROM Alternate_Recapture_Rate_Setting
						WHERE Program_Rebates_Component_Name_ID = #Program_Rebates_Component_Name_ID#
						AND Status = 0
					</cfquery>
				<!--- D38536	:: Alternate recapture rates per component END--->
				<!---62343 START --->
				<cfif appSettings.get_Setting('Blended_Rate') eq '1'>
					<cfset from_date = DATEFORMAT(qGetComps.Calculation_Period_Start, 'm/dd/yyyy')>
					<cfset to_date = DATEFORMAT(qGetComps.Calculation_Period_End, 'm/dd/yyyy')>
					<cfset Blended_Rate_On = qGetComps.Blended_Rate_On>
				<cfelse>
					<cfset from_date = "">
					<cfset to_date = "">
					<cfset Blended_Rate_On = 0>
				</cfif>

				<!--- 62343 END --->
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
							,Alternate_Recapture_Rate = ARSettings.recordcount // D38536	:: Alternate recapture rates per component
							,from_date = from_date
							,to_date = to_date
							,Blended_Rate_On = Blended_Rate_On
							,compRate=qGetComps.Component_Default_Rate //65711
							,compUOM=qGetComps.Component_Default_UOM //65711
							,IsSecondComponent=local.IsSecondComponent
							,DontCountVolume = qGetComps.Dont_Count_Volume
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
			<cfset prodCounter	= 0 />
			<cfset compCounter	= 1 />

		<cfquery name="variables.drop_tempdb" datasource="#application.datasource#">   <!--- 61108 --->
			IF OBJECT_ID('tempdb..##tmpAltRate') IS NOT NULL
			DROP TABLE ##tmpAltRate
		</cfquery>

		<cfquery name="qLoadAlternateRate" datasource="#application.datasource#">
			SELECT 	*
			INTO	##tmpAltRate
			FROM Program_Rebate_Alternate_Recapture_Rate
			WHERE Contract_Main_ID = #arguments.ProgramID#
		</cfquery>

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
					<cfset ItemUOM = qGetProds.Inventory_UM	/> <!--- Dev Note: KAL; 9588 --->
					<!---this is by group--->



					<cfif Is_Group EQ 1>
					<!--- Dev Note: drachala; D28957: Template EZ Button errors	 START
					Added/Changed: REMOVED ",FirstParentID = GetTemplateInfo.First_Parent_ID" --->
						<cfset qGetProduct = this.GroupDataManager.getByProductGroupData(prodGroupLevelId=qGetProds.Product_Group_Level_ID, prodGroupId=qGetProds.Product_Group_ID, programId=arguments.programID, byPassUserClassCodeRestriction=1, showAllProductHierarchy=1, IncludeDeleted=1,IncludeActiveOnly=0) />
					<!--- End Dev Note: drachala; D28957: Template EZ Button errors	--->
						<!---if product group level type is 2 then we know it's hierarchy so get the hierarchy id--->

						<cfif qGetProduct.Product_Group_Level_Type eq 2>
							<cfset thisItem = 	qGetProduct.Product_Hierarchy />
							<cfif qGetProduct.Unit_Of_Measure_ID EQ 1>
								<cfset ItemUOM	=	"CS" />
							<cfelseif qGetProduct.Unit_Of_Measure_ID EQ 2>
								<cfset ItemUOM	=	"LB" />
							</cfif>

						<cfelse>
							<cfset thisItem = 	"Group" /><!--- D38536	:: Alternate recapture rates per component--->
						</cfif>
						<cfset thisUPC 	=		"N/A" />
						<!---D35295:Update market pricing to use new group rates grid --->
						<!---<cfset thisDesc	=	qGetProduct.Group_Level_Desc />--->
						<cfset thisDesc	=	qGetProds.Description />
						<!---D35295:Update market pricing to use new group rates grid --->
						<cfset this.isGroup	=	1 />

						<cfset this.productGroupLevelTypeId = qGetProduct.Product_Group_Level_Type />
						<!---changed the item master id to the product group id--->
					<!--- 	<cfset thisItemMasterId = qGetProduct.Product_Group_ID /> --->

					<cfquery name="variables.update_tempdb" datasource="#application.datasource#">
						UPDATE ##tmpAProd
						SET Item = '#thisItem#'
						WHERE ItemId = '#qGetProds.BSA_Foodservice_Items_Master_ID#'
					</cfquery>
					<!---this is for all products--->
					<cfelseif Product_Group_Level_ID eq 1>

						<cfset qGetProduct = ProductGroupManager.getProductGroupDetails(qGetProds.Product_Group_Level_ID, qGetProds.Product_Group_ID) />
						<cfset thisItem = 	qGetProduct.item />
						<cfset thisUPC 	=		qGetProduct.upc />
						<cfset thisDesc	=	qGetProduct.description />
						<cfset this.isGroup	=	0 />
						<cfquery name="variables.update_tempdb" datasource="#application.datasource#">
							UPDATE ##tmpAProd
							SET Item = '#thisItem#', ItemDesc ='#thisDesc#'
							WHERE ItemId = '#qGetProds.BSA_Foodservice_Items_Master_ID#'
						</cfquery>

					<!---this is for item/product/sku--->
					<cfelse>

						<cfset thisItem = 	qGetProds.item />
						<cfset thisUPC 	=		qGetProds.upc />
						<cfset thisDesc	=	qGetProds.description />
						<cfset this.isGroup	=	0 />

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
							base sales are displayed on rebate page based on these 2 settings xxxxxxxxxxxxxxxxxxxx				--->
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
											//	USE FOB ---
											//local.BaseSalesLB = local.FOB_LB_Price;
											//local.BaseSalesCS = local.FOB_CS_Price;
											// USE DEL ---
											/*
											-	????*/

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
													,qGetProds.Blended_Base_Rate
													,qGetProds.Blended_Disc_Rate
													,qGetProds.Blended_Calc_Rate
													,qGetProds.Blended_Adj_Rate
													,Sleeves_Per_Case
													)
									) />
					<cfset lastItemMasterId = thisItemMasterId />
					<cfset prodCounter	= prodCounter + 1 />
					<cfset compCounter	= 1 />

					<cfscript>
						this.stRebate.aProd[prodCounter].Contract_Start_Date= thisContract_Start_Date;
						this.stRebate.aProd[prodCounter].Contract_End_Date= thisContract_End_Date;
						this.stRebate.aProd[prodCounter].IsExclusionRevision= thisIsExclusionRevision;
						this.stRebate.aProd[prodCounter].IsExclusionRevision= thisIsExclusionRevision;
						this.stRebate.aProd[prodCounter].Percentage_Of_List_Price = qGetProds.Percentage_Of_List_Price;
						this.stRebate.aProd[prodCounter].Price_List_ID = qGetProds.Price_List_ID;
						this.stRebate.aProd[prodCounter].Price_CS_DEL = qGetProds.Price_CS_DEL;
						this.stRebate.aProd[prodCounter].Price_CS_FOB = qGetProds.Price_CS_FOB;
						this.stRebate.aProd[prodCounter].Price_LB_DEL = qGetProds.Price_LB_DEL;
						this.stRebate.aProd[prodCounter].Price_LB_FOB = qGetProds.Price_LB_FOB;
					</cfscript>
				<cfelse>
					<cfset compCounter	= compCounter + 1 />
				</cfif>	<!--- if thisItemMasterId NEQ lastItemMasterId from 395 --->
				<!---set the contract id and product data id before going into nested loop--->
				<cfset conProdID = qGetProds.Contract_Products_ID />
				<cfset prodID = qGetProds.Program_Rebates_Product_Data_ID />



					<cfset rebate_rate = qGetProds.reb_rate />
					<cfset uom = qGetProds.unit_of_measure_id />
					<cfset UserSelectedUoM = 0 />
					<!----- for scan components if the uom selected by the user is "each", we store the rate entered by the user in the scan rate field
					and will store the cs equivalent values in the regular rate fields so that we do not have to change the rest of the application for now.
					once we have logic to handle uom="each" in other parts of the app we can remove the following conversion.

					if rebate type = Variable/Fixed Combo and uom=EA
					----->
					<CFIF trim(qGetProds.Program_Rebates_Component_ID) NEQ "" >

							<cftry>
								<!---63887 :: Need new UOM for Per Hundred Weight (CWT)  START --->
								<cfif qGetProds.User_Picked_UOM EQ 6>
									<cfset uom = 6>
									<cfset UserSelectedUoM = 6>
									<cfset rebate_rate = rebate_rate * 100>
								<cfelse>
									<cfset UserSelectedUoM = 0>
								</cfif>

						<cfif qGetProds.Scan_Uom eq 5 OR qGetProds.Scan_Uom eq 7>
							<cfset uom = qGetProds.Scan_Uom />
							<cfset rebate_rate = qGetProds.Scan_Rate />
							<cfset UserSelectedUoM = qGetProds.Scan_Uom />
						</cfif>

								<!---63887 :: Need new UOM for Per Hundred Weight (CWT)  END --->
								<cfscript>
										aCompVal = rate.set(
													rate=rebate_rate,
													uomID=uom,
													compID=qGetProds.Program_Rebates_Component_ID,
													contractProdID=conProdID,
													ruleId=qGetProds.Program_Rebates_Component_Rule_ID,
													basisCodeQuantity=qGetProds.Basis_Code_Quantity,
													basisCodeQuantityUom=qGetProds.Basis_Code_Quantity_UOM,
													basisCodeFreeGoods=qGetProds.Basis_Code_Free_Goods,
													effectMarginPercent=qGetProds.Effective_Margin_Percent,
													scanVolume=qGetProds.Scan_Volume,
													Program_Rebates_Component_Data_ID=qGetProds.Program_Rebates_Component_Data_ID,
													maxRate=qGetProds.EZ_Contract_Max_Rate,
													prodID=thisItemMasterId,
													ProgramID=qGetProds.Program_ID,
													UserSelectedUoM=UserSelectedUoM,
													arUseTempTable=1,
													EZTemplate = arguments.EZTemplate
													);
								</cfscript>

									<cfcatch type="any">
										<cfrethrow>
											<cfoutput>
												#rebate_rate# ::rate<br>
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
												#qGetProds.Scan_Volume#
											</cfoutput>
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
			<cfparam name="arguments.form.endRow"	 default="#ArrayLen(arguments.aProd)#">
			<cfparam name="form.displayedProductList" default="">

			<!---<cfif ArrayLen(arguments.aProd) LT arguments.form.endRow>
				<cfset arguments.form.endRow = ArrayLen(arguments.aProd)>
			</cfif>
			--->
			<cfset arguments.form.endRow = ArrayLen(arguments.aProd)>

			<cfscript>

				//start loop through the product array first
				session.nRebateSaveMax = arguments.form.endRow;

				for (i = arguments.form.startRow; i lte arguments.form.endRow; i = i+1)
				{
					if(listFindNoCase(form.displayedProductList,arguments.aProd[i].masterItemID) neq 0)
					{

						session.nRebateSaveProgress = i/arguments.form.endRow;
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
								/*61477 :: Upload Function Not Working
									hack fix, as not able to replicate this issue in stage and base.
									Issue: only first record in "DESREBATEDATA" struct have 2 values instead of 1
								*/
								if(listlen(arguments.aProd[i].productGroupLevelTypeId) GT 1){
									arguments.aProd[i].productGroupLevelTypeId = listgetat(arguments.aProd[i].productGroupLevelTypeId, 1);
								}
								if(listlen(arguments.aProd[i].pricingLevel) GT 1){
									arguments.aProd[i].pricingLevel = listgetat(arguments.aProd[i].pricingLevel, 1);
								}
								//61477 :: Upload Function Not Working END
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

						// D38536	:: Alternate recapture rates per component START
						for (j = 1; j	lte arguments.aComp[n].alternate_recapture_rate; j = j+1){
							if(IsDefined("arguments.form.arr_#j#_#prodIdVarName#_#compIdVarName#"))
							{
								arguments.aCompVal[i][n].ar_rate[j] =Evaluate("arguments.form.arr_#j#_#prodIdVarName#_#compIdVarName#");
								arguments.aCompVal[i][n].ar_uom[j] =Evaluate("arguments.form.arr_#j#_uom_#prodIdVarName#_#compIdVarName#");
							}
						}
						// D38536	:: Alternate recapture rates per component END

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
						scanRate = Evaluate("arguments.form.comp_rate_#prodIdVarName#_#compIdVarName#");
						scanUom = Evaluate("arguments.form.uom_#prodIdVarName#_#compIdVarName#");

						arguments.aCompVal[i][n].uomId = Evaluate("arguments.form.uom_#prodIdVarName#_#compIdVarName#");
						arguments.aCompVal[i][n].UserSelectedUoM = 0;

						if(arguments.aCompVal[i][n].uomId == 5 || arguments.aCompVal[i][n].uomId == 7){
							arguments.aCompVal[i][n].UserSelectedUoM = arguments.aCompVal[i][n].uomId;
							if(arguments.aCompVal[i][n].uomId == 5){
								arguments.aCompVal[i][n].rate =  Evaluate("arguments.form.comp_rate_#prodIdVarName#_#compIdVarName#") * arguments.aProd[i].EAConversion; // EA to CS
							}else{
								arguments.aCompVal[i][n].rate =  Evaluate("arguments.form.comp_rate_#prodIdVarName#_#compIdVarName#") * arguments.aProd[i].Sleeves_Per_Case;//SL to CS
							}

							arguments.aCompVal[i][n].uomId = 1;

							if(arguments.aProd[i].productInventoryUOM == "LB"){
								arguments.aCompVal[i][n].uomId = 2;
								arguments.aCompVal[i][n].rate = arguments.aCompVal[i][n].rate / arguments.aProd[i].Net_Weight;  // CS to LB
							}

						}else if(Evaluate("arguments.form.uom_#prodIdVarName#_#compIdVarName#") == 6){
							//63887 :: Need new UOM for Per Hundred Weight (CWT)  START
							arguments.aCompVal[i][n].uomId = 2;
							arguments.aCompVal[i][n].UserSelectedUoM = 6;
							arguments.aCompVal[i][n].rate = Evaluate("arguments.form.comp_rate_#prodIdVarName#_#compIdVarName#")/100;
						}else{
							arguments.aCompVal[i][n].uomId = Evaluate("arguments.form.uom_#prodIdVarName#_#compIdVarName#");
							arguments.aCompVal[i][n].UserSelectedUoM = 0;
							arguments.aCompVal[i][n].rate = Evaluate("arguments.form.comp_rate_#prodIdVarName#_#compIdVarName#");
						}
						//63887 :: Need new UOM for Per Hundred Weight (CWT) END
						if (action == "updSave")
						{
							arUpdSave[1] = arguments.aCompVal[i][n].rate;
							arUpdSave[2] = arguments.aCompVal[i][n].uomId;
							arUpdSave[3] = arguments.aCompVal[i][n].Program_Rebates_Component_Data_ID; //do not need form field since this is hidden we know it is in struct
							// pass scan volume D17948
							if(arguments.aComp[n].rebate_type EQ 4)
							{
								arUpdSave[6] = arguments.aCompVal[i][n].scanVolume;
							}
							else
							{
								arUpdSave[6] = "";
							}
							arUpdSave[8] = scanRate;
							arUpdSave[9] = scanUom;
							arUpdSave[7] = arguments.aCompVal[i][n].ruleId;
							arUpdSave[10] = arguments.aCompVal[i][n].Competitor_Price;
							arUpdSave[11] = arguments.aCompVal[i][n].Competitor_Name_ID;
							arUpdSave[12] = arguments.aCompVal[i][n].Competitor_Time_Frame;
							arUpdSave[13] = arguments.aCompVal[i][n].CompetitorSourceOther;
							// D38536	:: Alternate recapture rates per component START
							arUpdSave[14] = arguments.aComp[n].alternate_recapture_rate;
							arUpdSave[15] = arguments.aCompVal[i][n].contractprodid;
							arUpdSave[16] = arguments.aCompVal[i][n].ar_rate;
							arUpdSave[17] = arguments.aCompVal[i][n].ar_uom;
							arUpdSave[18] = arguments.aComp[n].compnameid;
							// D38536	:: Alternate recapture rates per component END

								/*61477 :: Upload Function Not Working
									hack fix, as not able to replicate this issue in stage and base.
									Issue: only first record in "DESREBATEDATA" struct have 2 values instead of 1
								*/
								if(listlen(arguments.aCompVal[i][n].rate) GT 1){
									arUpdSave[1] = listgetat(arguments.aCompVal[i][n].rate, 1);
								}
								if(listlen(arguments.aCompVal[i][n].uomId) GT 1){
									arUpdSave[2] = listgetat(arguments.aCompVal[i][n].uomId, 1);
								}
								//61477 :: Upload Function Not Working END
								arUpdSave[19] = '0';
                                                    if( isdefined("arguments.form.Blended_Rate_On_#n#") && Evaluate("arguments.form.Blended_Rate_On_#n#") ){
                                                        arUpdSave[20] = Evaluate("arguments.form.Blended_Base_Rate_#prodIdVarName#_#compIdVarName#");
                                                        arUpdSave[21] = Evaluate("arguments.form.Blended_Discount_Rate_#prodIdVarName#_#compIdVarName#");
                                                        arUpdSave[22] = Evaluate("arguments.form.Blended_Calculated_Rate_#prodIdVarName#_#compIdVarName#");
                                                        arUpdSave[23] = Evaluate("arguments.form.Blended_Adjustment_Rate_#prodIdVarName#_#compIdVarName#");
                                                    }
                                                    else{
                                                        arUpdSave[20] = '0';
                                                        arUpdSave[21] = '0';
                                                        arUpdSave[22] = '0';
                                                        arUpdSave[23] = '';
                                                    }
							arUpdSave[24] = arguments.aCompVal[i][n].UserSelectedUoM;

							this.saveProdRate(arUpdSave, 1);
							}

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
					//62343 8.0 - Blended Rate CF START
					if (isDefined("arguments.form.Force_Run_Blended_Vol_#n#")){
						this.stRebate.aComp[n].Force_Run_Blended_Vol = Evaluate("arguments.form.Force_Run_Blended_Vol_#n#");
					}
					if (isDefined("arguments.form.Blended_Start_Date_#n#")){
						this.stRebate.aComp[n].Blended_Start_Date = Evaluate("arguments.form.Blended_Start_Date_#n#");
					}
					if (isDefined("arguments.form.Blended_End_Date_#n#")){
						this.stRebate.aComp[n].Blended_End_Date = Evaluate("arguments.form.Blended_End_Date_#n#");
					}
					this.saveComponentInformation(this.stRebate.aComp[n]);
					if(this.stRebate.aComp[n].Blended_Rate_On){
						this.BlendedRateVolume (this.stRebate.aComp[n].ProgramId, this.stRebate.aComp[n].blended_rate_from_date,this.stRebate.aComp[n].blended_rate_to_date, this.stRebate.aComp[n].Force_Run_Blended_Vol,arguments.aProd[n].isGroup);
					}
					//62343 8.0 - Blended Rate CF END
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

		<cfscript>
		if (action == "updSave")
		{	/*  Dev Note(79237) - When a 2nd Component (Child of the first component) exists, then this function call is needed. */
			objPrgManager.updateSecondComponentRates('#arguments.programID#',2);
		}
		</cfscript>

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

		</cftry>	--->

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
			defaultUom = contract.getDefaultUom(arguments.contractMainID);
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
				//compValCopy =	duplicate(arguments.stDataStructure.aCompVal);
				//create an empty shell
				compValCopy[1]= rate.set(
																									rate = 0,
																									uomID = 1,
																									compID = 0,
																									contractProdID = 0,
																									ruleId = 0,
																									basisCodeQuantity = 0,
																									basisCodeQuantityUom = 0,
																									basisCodeFreeGoods = 0,
																									effectMarginPercent = 0,
																									scanVolume = 0,
																									Program_Rebates_Component_Data_ID = 0,
																									EZTemplate = arguments.EZTemplate
													);
				noProducts = true;
			</cfscript>
		</cfif>

		<!---we have components and products--->
		<cfif ArrayLen(arguments.stDataStructure.aProd) and ArrayLen(arguments.stDataStructure.aComp)>

			<cfscript>

				lastCompValCopy =	duplicate(arguments.stDataStructure.aCompVal[1]);
				contract = CreateObject("component", "components.programs.rebates.Contract");
				contractUom = contract.get(arguments.contractMainID);
				tmpUSDAComp = createObject("component","components.programs.rebates.RebateComponent");


				for (i=1; i lte ArrayLen(lastCompValCopy); i = i+1)
				{
					lastCompValCopy[i].rate = 0.000;
					lastCompValCopy[i].uomId = defaultUom;
					lastCompValCopy[i].UserSelectedUoM = 0;
				}

				hasProducts = true;

			</cfscript>

		</cfif>
		<!------ Get pricing level descriptions ----->
		<cfset qGetPricingLevel = this.GroupDataManager.getPricingLevel() />
		<cfset arPricingLevel = ListToArray(ValueList(qGetPricingLevel.Pricing_Level_Desc, ","), ",") />
		<cfset arPricingLevelLen = ArrayLen(arPricingLevel) />

		<!------ As there variable are not going to chnaged, moved outside the loop ----->

<!---77408 Product Group sequencing START--->
	<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
		<cfparam name="form.Level_#levels#" default="" />
	</cfloop>

	<cfset defaultLevelForProducts = request.AccessStructure.numberOfProductGroupLevels />
		<!---run logic to determine which level to put the products in--->

	<cfloop to="2" from="#request.AccessStructure.numberOfProductGroupLevels#" index="curLevel" step="-1">
		<cfset prevLevel = curLevel-1 />
		<cfif (trim(form["Level_#prevLevel#"]) neq "" and trim(form["Level_#curLevel#"]) eq "") or trim(form["GroupLevel_#curLevel#"]) eq 9>
			<cfset defaultLevelForProducts = curLevel />
		</cfif>
	</cfloop>

	<cfif (trim(form.Level_1) eq "" and trim(form.Level_2) eq "") or trim(form.GroupLevel_1) eq 9>
		<cfset defaultLevelForProducts = 1 />
	</cfif>
<!---77408 Product Group sequencing END--->

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
				<cfset qProductGroupValuesForItem 		= productGroupAttributeManager.getProductGroupValuesForItem(productGroupType=productGroupType,	productIDList	=arguments.lProdList) />
			</cfif>
		</cfif>

		<cfset originalCompVal = Duplicate(arguments.stDataStructure.aCompVal) />
		<cfset counter = 1 />
		<cfset qProgram = CreateObject("component", "components.programs.program").getProgramInfo(arguments.contractMainID) />
		<cfset tmpUSDAComp = createObject("component","components.programs.rebates.RebateComponent") />
		<cfset oPrdGrpDataManager = CreateObject("component", "components.products.Group.DataManager") />

        <!--- set up an array of product mappings :: prodIndex is the array product index in originalCompVal
                product_maps = [
                                    { prodID: "0261B33A-E08A-435B-BEC5-0DE6FAB142EA", prodIndex: 12 }
                                    ,{ prodID: "0A4792CB-402D-4657-842C-BCB28FFFE79F", prodIndex: 91 }
                                    ,{ prodID: "3736329C-3BA0-4836-8E82-83312D5403D1", prodIndex: 33 }
                                    ,{ prodID: "42838219-774B-4375-B485-34CA9547BD8", prodIndex: 16 }
                                ]
        --->
        <cfset local.product_maps = []>
        <cfloop from="1" to="#arrayLen(originalCompVal)#" index="local.pIndex">
            <cfif arrayLen(originalCompVal[local.pIndex]) gte 1>
                <cfset arrayAppend(local.product_maps, { prodID: originalCompVal[local.pIndex][1].prodID, prodIndex: local.pIndex })>
            </cfif>
        </cfloop>

        <!---
            set up a large structure with all product IDs as keys and store the indexes in the originalCompVal array as values
            (e.g. product_index {
                                    0261B33A-E08A-435B-BEC5-0DE6FAB142EA: 12
                                    ,0A4792CB-402D-4657-842C-BCB28FFFE79F: 91
                                    ,3736329C-3BA0-4836-8E82-83312D5403D1: 33
                                    ,42838219-774B-4375-B485-34CA9547BD84: 16
                                }
                if there are 1,500 products in program this large structure would have 1,500 keys
            )
            We will use the large structure to the lookup the array index instead of slowly looping through the large 2 dimensional array
            (Tyson reported performance issues in importing new products in program with more than 1,500 products)

            see more detail information written by Ben Nadel at
            https://www.bennadel.com/blog/3063-using-structs-as-data-lookup-indices-in-coldfusion-data-manipulation.htm
        --->
        <cfset local.product_index = {}>
        <cfloop from="1" to="#arrayLen(product_maps)#" index="local.pIndex">
            <cfset local.product_index[ product_maps[local.pIndex].prodID ] = product_maps[local.pIndex].prodIndex>
        </cfloop>

		<cfloop index="prodID" list="#arguments.lProdList#">

			<!---strip hyphens--->
			<cfset prodIdNoHyphen = request.app_general_functions.replaceHyphen(prodID) />

			<cfparam name="form.Product_Group_Level_ID_#prodIdNoHyphen#" default="0" />
			<cfparam name="form.Product_Group_ID_#prodIdNoHyphen#" default="" />
			<cfparam name="form.Pricing_Level_ID_#prodIdNoHyphen#" default="0" />
			<cfparam name="form.Is_Group_#prodIdNoHyphen#" default="0" />
			<cfparam name="form.Product_Group_Level_Type_ID_#prodIdNoHyphen#" default="" />
			<cfparam name="form.Prod_Default_#prodIdNoHyphen#" default="0" />

			<cfset productGroupLevel 	= 0>
			<cfset productGroupID 		= 0>

			<cfset this.Inventory_UM 	= "" />
			<cfset this.EAConversion = 1 />
			<cfset this.Sleeves_Per_Case = 1 />

			<!---this is for adding just straight products--->
            <cfif productGroupLevel EQ 0 and Evaluate("form.Is_Group_#prodIdNoHyphen#") neq 1>

				<cfquery name="qGetProduct" datasource="#application.datasource#">
					SELECT 	item,
									upc,
									description,
									Inventory_UM,
									ISNULL(BSA_Foodservice_Items_Master.Case_Count, 1) as EA_Conversion,
									CASE
										WHEN ISNULL(BSA_Foodservice_Items_Master.Sleeves_Per_Case, 0) = 0 THEN 1
										ELSE ISNULL(BSA_Foodservice_Items_Master.Sleeves_Per_Case, 1) end as Sleeves_Per_Case,
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
				<cfset this.Sleeves_Per_Case = qGetProduct.Sleeves_Per_Case />
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
																		Competitor_Time_Frame,
																		this.Sleeves_Per_Case
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
						currentRate =	0;
						uomDefault = defaultUom;
						UOM = uomDefault;
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
																	rate = currentRate,
																	uomID = UOM,
																	compID = 0,
																	contractProdID = 0,
																	ruleId = 0,
																	basisCodeQuantity = 0,
																	basisCodeQuantityUom = 0,
																	basisCodeFreeGoods = 0,
																	effectMarginPercent = 0,
																	scanVolume = 0,
																	Program_Rebates_Component_Data_ID = 0,
																	maxRate = maxRate,
																	prodID = prodID,
																	EZTemplate = arguments.EZTemplate
																	);
							}
						tmpCompVal[compIndx] = Duplicate(lastCompValCopy[compIndx]);
					</cfscript>
					<!---set comp id with no hyphens--->
					<cfset compIdNoHyphen = request.app_general_functions.replaceHyphen(arguments.stDataStructure.aComp[compIndx].compUUID) />

					<!---param uomId and rate--->
					<!--- <cfif StructKeyExists()></cfif> --->
					<!--- <cfif ArrayIsDefined(arguments.stDataStructure.aCompVal, counter) > --->

					<cfif ArrayLen(arguments.stDataStructure.aCompVal) GTE	counter>
						<!--- <cfif ArrayIsDefined(arguments.stDataStructure.aCompVal[counter], compIndx)> --->
						<cfif ArrayLen(arguments.stDataStructure.aCompVal[counter]) GTE compIndx>
							<!---if the max products to display is less than the amount of rebate products
							then default the rate and uom to what's in the data structure --->
							<cfif ArrayLen(arguments.stDataStructure.aProd) gt this.getMaxProducts()>
                                <cfif not isDefined("form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#") or not isDefined("form.uom_#prodIdNoHyphen#_#compIdNoHyphen#")>
                                    <cfset stComponentRate = ( structKeyExists(product_index, prodID)
                                                                ? originalCompVal[product_index[ prodID ]][compIndx]
                                                                : lastCompValCopy[compIndx])>

									<cfparam name="form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#" default="#stComponentRate.rate#" />
									<cfparam name="form.uom_#prodIdNoHyphen#_#compIdNoHyphen#" default="#stComponentRate.uomId#" />

									<!--- Dev Note: drachala; D27521: HZPROD283	SARP PRG message . This value is greater than the template	START--->
										<!--- Get max rate from originalCompVal
											When products are deleted from templated, we are retainng max price when they are created. --->
									<cfparam name="form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#_Tmplt" default="#stComponentRate.MaxRate#" />
									<!--- Dev Note: drachala; D27521: HZPROD283	SARP PRG message . This value is greater than the template	END--->
		 						</cfif>
							<cfelse>
								<cfparam name="form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#" default="0" />
								<cfparam name="form.uom_#prodIdNoHyphen#_#compIdNoHyphen#" default="#uomDefault#" />

							</cfif>
						<cfelse>
							<cfparam name="form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#" default="#lastCompValCopy[compIndx].rate#" />
							<cfparam name="form.uom_#prodIdNoHyphen#_#compIdNoHyphen#" default="#lastCompValCopy[compIndx].uomId#" />
						</cfif>
					<cfelse>
						<cfif ArrayLen(arguments.stDataStructure.aProd) gt this.getMaxProducts()>
							<cfif not isDefined("form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#") or not isDefined("form.uom_#prodIdNoHyphen#_#compIdNoHyphen#")>
                                <cfset stComponentRate = ( structKeyExists(product_index, prodID)
                                                            ? originalCompVal[product_index[ prodID ]][compIndx]
                                                            : lastCompValCopy[compIndx])>

								<cfparam name="form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#" default="#stComponentRate.rate#" />
								<cfparam name="form.uom_#prodIdNoHyphen#_#compIdNoHyphen#" default="#stComponentRate.uomId#" />

								<!--- Dev Note: drachala; D27521: HZPROD283	SARP PRG message . This value is greater than the template	START--->
								<!--- Get max rate from originalCompVal When products are deleted from templated, we are retainng max price when they are created. --->
								<cfparam name="form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#_Tmplt" default="#stComponentRate.MaxRate#" />
								<!--- Dev Note: drachala; D27521: HZPROD283	SARP PRG message . This value is greater than the template	END--->
							</cfif>
						<cfelse>
							<cfparam name="form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#" default="#lastCompValCopy[compIndx].rate#" />
							<cfparam name="form.uom_#prodIdNoHyphen#_#compIdNoHyphen#" default="#lastCompValCopy[compIndx].uomId#" />
						</cfif>
					</cfif>
                   <!--- <cfif Evaluate("form.uom_#prodIdNoHyphen#_#compIdNoHyphen#") EQ 6>
                        <cfset "form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#" = Evaluate("form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#")/100>
                    </cfif> --->
					<!---set rate and uom in aCompVal--->
					<cfif NOT isNumeric(arguments.stDataStructure.aComp[compIndx].compNameID)>
						<cfset tmpCompNameID = 0>
					<cfelse>
						<cfset tmpCompNameID = arguments.stDataStructure.aComp[compIndx].compNameID>
					</cfif>

					<cfif NOT tmpUSDAComp.isUSDANOIComp(tmpCompNameID)>
						<cfset tmpCompVal[compIndx].rate = Evaluate("form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#") />

							<!--- Dev Note: drachala; D27521: HZPROD283	SARP PRG message . This value is greater than the template	START--->
								<!--- Get max rate from originalCompVal When products are deleted from templated, we are retainng max price when they are created. --->
						<cfif isDefined("form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#_Tmplt")>
							<cfset maxrate = form["comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#_Tmplt"] />
						</cfif>
							<!--- Dev Note: drachala; D27521: HZPROD283	SARP PRG message . This value is greater than the template	END--->
						<cfset tmpCompVal[compIndx].maxrate = maxrate />
					<cfelse>
						<cfset tmpCompVal[compIndx].rate = tmpUSDAComp.getUSDACompRate(prodID)>
						<cfset tmpCompVal[compIndx].maxrate = maxrate />
					</cfif>
					<!--- <cfset tmpCompVal[compIndx].uomId = Evaluate("form.uom_#prodIdNoHyphen#_#compIdNoHyphen#") /> --->
					<!--- XXXXXXXXXXXXXXXX  WR 77502 Fixes for CWT issues when importing new Products   XXXXXXXXXXXXXXXXXX --->
					<cfscript>
						if(Evaluate("form.uom_#prodIdNoHyphen#_#compIdNoHyphen#") == 6){
								tmpCompVal[compIndx].uomId = 2;
								tmpCompVal[compIndx].UserSelectedUoM = 6;
								tmpCompVal[compIndx].rate = Evaluate("form.comp_rate_#prodIdNoHyphen#_#compIdNoHyphen#")/100;
							}else{
								tmpCompVal[compIndx].uomId = Evaluate("form.uom_#prodIdNoHyphen#_#compIdNoHyphen#");
								tmpCompVal[compIndx].UserSelectedUoM = 0;
						}
					</cfscript>
					<!--- XXXXXXXXXXXXXXXX WR 77502 END  XXXXXXXXXXXXXXXXXX --->

					<cfloop index="j" from="1" to="#arguments.stDataStructure.aComp[compIndx].alternate_recapture_rate#">
						<cfparam name="form.arr_#j#_#prodIdNoHyphen#_#compIdNoHyphen#" default="0" />
						<cfparam name="form.arr_#j#_uom_#prodIdNoHyphen#_#compIdNoHyphen#" default="0" />

						<cfset tmpCompVal[compIndx].ar_rate[j] =Evaluate("form.arr_#j#_#prodIdNoHyphen#_#compIdNoHyphen#") />
						<cfset tmpCompVal[compIndx].ar_uom[j] =Evaluate("form.arr_#j#_uom_#prodIdNoHyphen#_#compIdNoHyphen#") />
					</cfloop>
				</cfloop>

				<!---now set to aCompVal key--->
				<cfset arguments.stDataStructure.aCompVal[counter] = tmpCompVal />

			</cfif>

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

		<cfquery name="getPCPODetail" datasource="#application.datasource#">
			SELECT Ignore_Rebate_Volume FROM Program_Control_Panel_Options PCPO
			INNER JOIN Contract_Main CM ON CM.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID
			WHERE CM.Contract_Main_ID = <cfqueryparam value="#arguments.contractMainID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfset DontCountVolume = 0 />
		<cfif (isDefined("getPCPODetail") AND getPCPODetail.RecordCount NEQ 0 AND getPCPODetail.Ignore_Rebate_Volume EQ 1)>
			<cfset DontCountVolume = 1 />
		</cfif>
		<cfscript>

			//create instances of components
			comp = createObject("component","components.programs.rebates.RebateComponent");
			compRate = createObject("component","components.programs.rebates.RebateComponentRate");
			USDAComp = comp.isUSDANOIComp(arguments.formScope.compNameId);

			//62343 8.0 - Blended Rate, CF START
			if (not isDefined("arguments.formScope.from_date")){
				arguments.formScope.from_date = '';
			}
			if (not isDefined("arguments.formScope.to_date")){
				arguments.formScope.to_date = '';
			}
			if (not isDefined("arguments.formScope.Blended_Rate_On")){
				arguments.formScope.Blended_Rate_On = 0;
			}
			//-62343 8.0 - Blended Rate, CF END

			//if rate wasn't added then set to 0
			if (trim(arguments.formScope.rate) eq ""){
				arguments.formScope.rate = 0.000;
			}

			if (not isDefined("arguments.formScope.GL_Account_ID")){
				arguments.formScope.GL_Account_ID = 0;
			}

			if (not isDefined("arguments.formScope.Vendor_Master_ID")){
				arguments.formScope.Vendor_Master_ID = 0;
			}

			if (not comp.checkExists(arguments.stDataStructure.aComp,arguments.formScope.compUUID)){
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
													arguments.formScope.Payee_Selection,
													"0",
													arguments.formScope.from_date,
													arguments.formScope.to_date,
													arguments.formScope.Blended_Rate_On,
													arguments.formScope.rate,
													arguments.formScope.uom,
													"0",
													DontCountVolume
													)
												);


				UOM = arguments.formScope.UOM;
				maxRate = 0;
				//if the aProd array holds data then append for each element, otherwise add by assignment
				if (ArrayLen(arguments.stDataStructure.aProd)){
					//if the aCompVal array holds data then we can append to it, otherwise we have to add to the array by assignment
					if (ArrayLen(arguments.stDataStructure.aCompVal)){
						for (i=1; i lte ArrayLen(arguments.stDataStructure.aProd); i=i+1)	{

								// Added for 21553
							currentRate = arguments.formScope.rate;
							UOM = arguments.formScope.UOM;
							maxRate = 0;

							if ((arguments.stDataStructure.aProd[i].EZ_Contract_Id NEQ 0) AND (arguments.stDataStructure.aProd[i].EZ_Contract_Id NEQ "") AND arguments.EZTemplate EQ 0)	{ // addComp
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
									currentRate =	ezRate.Rate;
								}else{
								// is Ezbutton AND Max Rate AND	Template settings Enter Beyond Max Rate --- YES
									if(EZABOVEMaxRateOn){
									 	currentRate = arguments.formScope.rate;
									 }
									 else if(currentRate GT maxRate){
									 	currentRate = " ";
									 }else{
									 	currentRate = arguments.formScope.rate;
									 }
								}

							}

							if(arguments.level3RateCanBeNull AND arguments.stDataStructure.aProd[i].pricingLevel EQ 3){
								currentRate = 0;
							}

							if( NOT USDAComp) {
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
						}//FOR END
					}else{
						for (i=1; i lte ArrayLen(arguments.stDataStructure.aProd); i=i+1)	{

							// Added for 21553

							currentRate = arguments.formScope.rate;
							UOM = arguments.formScope.UOM;
							maxRate = 0;

							if ((arguments.stDataStructure.aProd[i].EZ_Contract_Id NEQ 0) AND (arguments.stDataStructure.aProd[i].EZ_Contract_Id NEQ "") AND arguments.EZTemplate EQ 0)	{ // addComp
								ezRate = getRebateProductComponentRate(
										arguments.stDataStructure.aProd[i].EZ_Contract_Id,
										arguments.stDataStructure.aProd[i].masterItemID,
										arguments.formScope.compNameId,
										arguments.formScope.Component_Paid_To);

								/*UOM = ezRate.UOM ;D45434	 :: When EZ button is on UOM selected on default rate is overridden by UOM from EZ Button*/
								maxRate = ezRate.rate;
								/*Dev Note: Drachala; D27506 : EZ Button, max rate - allow user to enter default rate and mass apply rate START*/
								if(!arguments.EZMaxRateOn){
								currentRate =	ezRate.Rate;
								}
								else{
								// is Ezbutton AND Max Rate AND	Template settings Enter Beyond Max Rate --- YES
									if(EZABOVEMaxRateOn){
									 		currentRate = arguments.formScope.rate;
									 }
									 else if(currentRate GT maxRate){
									 	currentRate = " ";
									 }
									 else{
									 	currentRate = arguments.formScope.rate;
									 }

								}

							}


							if(arguments.level3RateCanBeNull AND arguments.stDataStructure.aProd[i].pricingLevel EQ 3){
								currentRate = 0;
							}
								tmpArray = ArrayNew(1);
									if( NOT USDAComp) {
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
						}//FOR END
					}//ELSE END
				}//IF END
}//FIRST IF END
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

			<cfset tmpArray =	ArrayNew(1) />
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

	<cffunction name="remComp" output="false" returntype="void">

		<cfargument name="programId" type="numeric" required="true" default="" />
		<cfargument name="programComponentID" type="numeric" required="true" default="" />

		<cfset UpdStatus = UpdateGroupStatus(arguments.programId)>

		<cfquery name="qDropTble" datasource="#application.datasource#">   <!--- 61108 --->
			IF OBJECT_ID('tempdb..##tmp_getProgCompInfo') IS NOT NULL
			DROP TABLE ##tmp_getProgCompInfo
		</cfquery>

		<cfquery name="qGetPRC" datasource="#application.datasource#">   <!--- 61108 --->
			SELECT	Program_Rebates_Component_ID
			INTO	##tmp_getProgCompInfo
			FROM	Program_Rebates_Component rc
			WHERE	rc.Program_Rebates_Component_ID = #arguments.programComponentID#
			AND		rc.Program_ID = #arguments.programId#
			AND		rc.Deleted = 0
		</cfquery>

		<cfquery name="qDeletePRCD" datasource="#application.datasource#">   <!--- 61108 --->
			UPDATE	PRCD
			SET		Deleted = 1
			FROM	Program_Rebates_Component_Data PRCD
			WHERE	EXISTS (SELECT 1 FROM ##tmp_getProgCompInfo t WHERE t.Program_Rebates_Component_ID = PRCD.Program_Rebates_Component_ID)
			AND		Deleted = 0
		</cfquery>

		<cfquery name="qDeleteAltRate" datasource="#application.datasource#">   <!--- 61108 --->
			DELETE	Program_Rebate_Alternate_Recapture_Rate
			WHERE	Contract_Main_ID = #arguments.programId#
			AND		EXISTS (SELECT 1 FROM ##tmp_getProgCompInfo t WHERE t.Program_Rebates_Component_ID = Program_Rebate_Alternate_Recapture_Rate.Program_Rebates_Component_ID)
		</cfquery>

		<cfquery name="qDeleteAltRate" datasource="#application.datasource#">   <!--- 61108 --->
			UPDATE	PPC
			SET		Deleted = 1
			FROM	Program_Payment_Cycle PPC
			WHERE	Program_ID = #arguments.programId#
			AND 	Discount_Type_ID = 2
			AND		EXISTS (SELECT 1 FROM ##tmp_getProgCompInfo t WHERE t.Program_Rebates_Component_ID = PPC.Component_ID)
			AND		Deleted = 0
		</cfquery>

		<cfquery name="qDeletePRC" datasource="#application.datasource#">   <!--- 61108 --->
			UPDATE	PRC
			SET		Deleted = 1
			FROM	Program_Rebates_Component PRC
			WHERE	EXISTS (SELECT 1 FROM ##tmp_getProgCompInfo t WHERE t.Program_Rebates_Component_ID = PRC.Program_Rebates_Component_ID)
			AND		Deleted = 0
		</cfquery>

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
		<cfargument name="fromMassApply" required="false" default="0"><!--- D38846 ::	Recapture changes START--->
		<cfargument name="RevisonUOMDisable" required="false" default="0">

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
						<!--- <cfset ar_mass_Check = arraynew(1)>D38846 ::	Recapture changes --->
						<cfset componentPosition = ListGetAt(arguments.lComp,n) />
						<cfparam name="arguments.stDataStructure.aComp[componentPosition].Blended_Rate_On" default="0">
						<cfset basisCodeType = 0 />
						<cfif arguments.Display_Basis_Treatment_Code EQ 1>
							<cfif BasisCodeManager.getBasicCodeType(arguments.stDataStructure.aComp[componentPosition].BasisCode) EQ "Y">
								<cfset basisCodeType = 1 />
							</cfif>
						</cfif>
						<!--- D38846 ::	Recapture changes START
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
						D38846 ::	Recapture changes END--->
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
												 {		//removed LT check since EZABOVEMaxRateOn says user can enter rate above maxrate
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
												 			 //only convert cs -> lb or lb -> cs.	let % fall through.
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

									if (trim(arguments.uom) && arguments.RevisonUOMDisable == 0){
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
									userSelectedUOM = variables.uom;
									if(variables.uom == 5 || variables.uom == 7)
									{
										variables.uom = 1;
										if(variables.uom == 5){
											_rate = _rate * arguments.stDataStructure.aProd[i].EAConversion; // EA to CS
										}else{
											_rate = _rate * arguments.stDataStructure.aProd[i].Sleeves_Per_Case; // SL to CS
										}

										if(arguments.stDataStructure.aProd[i].productInventoryUOM == "LB")
										{
											variables.uom = 2;
											_rate = _rate / arguments.stDataStructure.aProd[i].Net_Weight; // CS to LB
										}

									}

									if (Len(trim(arguments.rate)) and trim(variables.uom) and action == "updSave")
									{ //write this to the DB and be done
										arUpdSave[1] = _rate;
										arUpdSave[2] = variables.uom;
										arUpdSave[3] = arguments.stDataStructure.aCompVal[indx][componentPosition].Program_Rebates_Component_Data_ID; //do not need form field since this is hidden we know it is in struct
										//arUpdSave[4] = "";
										//arUpdSave[5] = "";

										arUpdSave[8] = scanRate;
										arUpdSave[9] = scanUom;

										if(arguments.stDataStructure.aComp[n].rebate_type == 4)
										{
											arUpdSave[6] = arguments.stDataStructure.aCompVal[indx][componentPosition].scanVolume;
										}
										else
										{
											arUpdSave[6] = "";
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
										//D38846 ::	Recapture changes START
										arUpdSave[19] = arguments.fromMassApply;
										//D38846 ::	Recapture changes END

										if(arguments.stDataStructure.aComp[componentPosition].Blended_Rate_On){
											arUpdSave[20] = arguments.stDataStructure.aProd[i].Blended_Base_Rate;
											arUpdSave[21] = arguments.stDataStructure.aProd[i].Blended_Discount_Rate;
											arUpdSave[22] = arguments.stDataStructure.aProd[i].Blended_Calc_Rate;
											arUpdSave[23] = arguments.stDataStructure.aProd[i].Blended_Adj_Rate;
										}
										else{
											arUpdSave[20] = '0';
											arUpdSave[21] = '0';
											arUpdSave[22] = '0';
											arUpdSave[23] = '';
										}

										arUpdSave[24] = userSelectedUOM;
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

		<cfscript>
		if (action == "updSave")
		{	/*  Dev Note(79237) - When a 2nd Component (Child of the first component) exists, then this function call is needed. */
			objPrgManager.updateSecondComponentRates(arguments.stDataStructure.aComp[componentPosition].programID,2);
		}
		</cfscript>

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
		FROM	PG_Product_Members WHERE
			BSA_Foodservice_Items_Master_ID	= '#arguments.BSA_Foodservice_Items_Master_ID#'
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
						<cfset varGroupLevelID =	strRow[2] />
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
			<!--- If the temp table does not exist, create either the one with a group attribute or one without (depending on whether groups exist or not)	--->
				<cfif Table_Created eq 0>
					<cfif Groups_Exist	eq 1 AND Field_Name neq "">
						<cfquery datasource="#application.datasource#">
						CREATE TABLE ##qTmp (
											oldArrayIndx	Int	Identity (1,1) PRIMARY KEY CLUSTERED,
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
												oldArrayIndx	Int	Identity (1,1) PRIMARY KEY CLUSTERED,
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
'#arguments.stDataStructure.aProd[i].EZ_Contract_Id#','#arguments.stDataStructure.aProd[i].basesalescs#','#replace(arguments.stDataStructure.aProd[i].GroupNumber,"'","","all")#')<!--- D30357:Today's Price Wrong on Revision History END--->
</cfloop>
</cfsavecontent>

				<cfelse>

				<!--- If there are no groups --->
					<!--- <cfquery datasource="#application.datasource#"> --->
<cfsavecontent variable="tmpsql">
<cfloop from="1" to="#ArrayLen(arguments.stDataStructure.aProd)#" index="i">insert into ##qTmp values('#trim(left(arguments.stDataStructure.aProd[i].item,50))#','#trim(left(arguments.stDataStructure.aProd[i].upc,50))#','#trim(replace(left(arguments.stDataStructure.aProd[i].description,50),"'","","all"))#','#trim(arguments.stDataStructure.aProd[i].pricingLevel)#','#replace(trim(left(arguments.stDataStructure.aProd[i].displaygroupname,50)),"'","","all")#','#trim(left(arguments.stDataStructure.aProd[i].masterItemID,37))#','#trim(arguments.stDataStructure.aProd[i].productGroupLevel)#','#trim(left(arguments.stDataStructure.aProd[i].productGroupID,37))#','#trim(arguments.stDataStructure.aProd[i].isGroup)#','#trim(arguments.stDataStructure.aProd[i].EZButton_On_Default)#',
'#arguments.stDataStructure.aProd[i].EZ_Contract_Id#','#arguments.stDataStructure.aProd[i].basesalescs#', '#replace(arguments.stDataStructure.aProd[i].GroupNumber,"'","","all")#') <!--- D30357:Today's Price Wrong on Revision History END---></cfloop>
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
							oldArrayIndx	Int	Identity (1,1) PRIMARY KEY CLUSTERED,
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
		<cfset var iTxtPercentage = "" />
		<cfset var isPercentNull = "Yes" />
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

		<!--- START: D48146: % of List Price --->
		<cfif appSettings.get_Setting('Percentage_Of_List_Price') EQ '1'>
			<cfquery name="GetTemplateInfoListPrice" datasource="#application.datasource#">
		 		SELECT	First_parent_ID,
						Percentage_Of_List_Price,
					   	Price_List_ID
				FROM	Program_Control_Panel_Options
				INNER JOIN Contract_Main
				ON		Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
				AND 	Contract_Main.Contract_Main_ID = #arguments.rebateData.programId#
				WHERE	Program_Control_Panel_Options.Deleted = 0
			</cfquery>
			<cfif (GetTemplateInfoListPrice.Percentage_Of_List_Price EQ '1') AND isDefined("FORM.txtPercentage")>
				<cfset iTxtPercentage = FORM.txtPercentage />
				<cfset isPercentNull = "No" />
			<cfelse>
				<cfset isPercentNull = "Yes" />
			</cfif>
		</cfif>
		<!--- END: D48146: % of List Price --->

		<cfquery datasource="#application.datasource#">
			if object_id('tempdb..##TMP_Program_Rebates_Component_Data') is not null
			drop table ##TMP_Program_Rebates_Component_Data
		</cfquery>
	<cfquery datasource="#application.datasource#">
		CREATE TABLE ##TMP_Program_Rebates_Component_Data(
			Program_Rebates_Component_ID INT,
			Program_Rebates_Product_Data_ID BIGINT,
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
			,Blended_Base_Rate DECIMAL(20,4)
			,Blended_Disc_Rate DECIMAL(20,4)
			,Blended_Calc_Rate DECIMAL(20,4)
			,Blended_Adj_Rate DECIMAL(20,4)
			,User_picked_UOM INT
		)
	</cfquery>

		<cfquery name="qCheckAltRates" datasource="#application.datasource#">
			select 	1
			from 	Program_Rebate_Alternate_Recapture_Rate
			where 	Contract_Main_ID = #arguments.rebateData.programId#
		</cfquery>


		<cfif qCheckAltRates.RecordCount>
			<cfquery datasource="#application.datasource#">
				delete from Program_Rebate_Alternate_Recapture_Rate where Contract_Main_ID = #arguments.rebateData.programId#
			</cfquery>
		</cfif>


			<!---set deleted to 1 for all tables in this transaction--->
			<cfquery datasource="#application.datasource#">
				--UPDATE 	Contract_Products
				--SET 	Deleted = 1
				DELETE FROM Contract_Products
				WHERE	Contract_Main_ID = #arguments.rebateData.programId#
				AND		Product_Type_ID = 2
				--AND		Deleted = 0



				--UPDATE 	Contract_Product_Margin
				--SET 	Deleted = 1
				DELETE FROM Contract_Product_Margin
				WHERE	Contract_Main_ID = #arguments.rebateData.programId#
				AND		Product_Type_ID = 2
				--AND		Deleted = 0



				--UPDATE 	Program_Rebates_Product_Data
				--SET 	Deleted = 1
				DELETE FROM Program_Rebates_Product_Data
				WHERE	program_id = #arguments.rebateData.programId#
				--AND		Deleted = 0
			</cfquery>

			<cfset useLakebaseForqGetCompIds = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_component")>
<cfif useLakebaseForqGetCompIds>
	<cftry>
		<cfset qGetCompIds = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_rebates_component", {
				"program_id" = "eq.#arguments.rebateData.programId#",
				"select" = "program_rebates_component_id"
			}), "program_rebates_component_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetCompIds = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetCompIds>
<cfquery name="qGetCompIds" datasource="#application.datasource#">
				SELECT 	Program_Rebates_Component_ID
				FROM	Program_Rebates_Component
				WHERE	Program_ID = #arguments.rebateData.programId#
			</cfquery>
</cfif>

			<cfif qGetCompIds.RecordCount>

				<cfquery datasource="#application.datasource#">
					--UPDATE 	Program_Rebates_Component_Data
					--SET 	Deleted = 1
					DELETE FROM Program_Rebates_Component_Data
					WHERE	Program_Rebates_Component_ID in (#QuotedValueList(qGetCompIds.Program_Rebates_Component_ID)#)
					--AND		Deleted = 0
				</cfquery>

			</cfif>

			<!--- Tim Ford - 01/25/2016: WR 56932 - VOLUME OVERRRIDE LOGIC - CURRENT DESIGN AFFECTS PRODUCTIVITY
			Retain the selected value for Dont_Count_Volume from Program_Fixed_Component
			--->
			<cfset useLakebaseForqGetVolumeOverrideSelection = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_component")>
<cfif useLakebaseForqGetVolumeOverrideSelection>
	<cftry>
		<cfset qGetVolumeOverrideSelection = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_rebates_component", {
				"deleted" = "eq.0",
				"program_id" = "eq.#arguments.rebateData.programId#",
				"dont_count_volume" = "eq.1",
				"select" = "dont_count_volume,program_rebates_component_name_id"
			}), "dont_count_volume,program_rebates_component_name_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetVolumeOverrideSelection = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetVolumeOverrideSelection>
<CFQUERY NAME="qGetVolumeOverrideSelection" datasource="#application.datasource#">
				SELECT	DISTINCT Dont_Count_Volume, Program_Rebates_Component_Name_ID
				FROM	Program_Rebates_Component
				WHERE	Deleted = 0
				AND		Program_ID = #arguments.rebateData.programId#
				AND		Dont_Count_Volume = 1
			</CFQUERY>
</cfif>

			<cfquery datasource="#application.datasource#">
				--UPDATE 	Program_Rebates_Component
				--SET 	Deleted = 1
				DELETE FROM Program_Rebates_Component
				WHERE	Program_ID = #arguments.rebateData.programId#
				--AND		Deleted = 0
			</cfquery>

			<cfset allProductSelected = false>



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
				<!--- Tim Ford - 01/25/2016: WR 56932 - VOLUME OVERRRIDE LOGIC - CURRENT DESIGN AFFECTS PRODUCTIVITY
				Retain the selected value for Dont_Count_Volume from Program_Fixed_Component
				--->
				<cfset variables.bDontCountVolume = 0 />
				<cfset useLakebaseForqGetVolOverrideTemp = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetvolumeoverrideselection")>
<cfif useLakebaseForqGetVolOverrideTemp>
	<cftry>
		<cfset qGetVolOverrideTemp = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetvolumeoverrideselection", {
				"program_rebates_component_name_id" = "eq.#arguments.rebateData.aComp[n].compNameId#",
				"select" = "dont_count_volume"
			}), "dont_count_volume"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetVolOverrideTemp = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetVolOverrideTemp>
<CFQUERY NAME="qGetVolOverrideTemp" dbtype="query">
					SELECT	Dont_Count_Volume
					FROM	qGetVolumeOverrideSelection
					WHERE	Program_Rebates_Component_Name_ID = #arguments.rebateData.aComp[n].compNameId#
				</CFQUERY>
</cfif>
				<cfif qGetVolOverrideTemp.RecordCount>
					<cfset variables.bDontCountVolume = qGetVolOverrideTemp.Dont_Count_Volume />
				</cfif>


				<cfquery name="qInsertComps" datasource="#application.datasource#">
					<!---
					There is a scenario where we are having duplicates in Program_Rebates_Component.
					Could be due to double click or page reload by user, but we are not able to recreate.
					Checking if the component already exist before inserting to avoid duplication.
					--->
					IF NOT EXISTS (
						SELECT 	1
						FROM 	Program_Rebates_Component C
						WHERE 	C.Program_ID = <cfqueryparam value="#arguments.rebateData.programId#" cfsqltype="CF_SQL_INTEGER">
						AND		C.Program_Rebates_Component_Name_ID = <cfqueryparam value="#arguments.rebateData.aComp[n].compNameId#" cfsqltype="CF_SQL_INTEGER">
						AND		C.Component_Paid_To = <cfqueryparam value="#arguments.rebateData.aComp[n].componentPaidTo#" cfsqltype="CF_SQL_INTEGER">
						AND		C.Deleted = 0
					)
					BEGIN
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
						Parent_Program_Rebates_Component_ID,
						Percentage_Of_List_Price,
						Dont_Count_Volume
						,Calculation_Period_Start ---62343 8.0 - Blended Rate, CF
						,Calculation_Period_End ---62343 8.0 - Blended Rate, CF
						,Component_Default_Rate ---65711
						,Component_Default_UOM ---65711
						)
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
						<cfqueryparam value="#arguments.rebateData.aComp[n].ParentProgramRebatesComponentID#" cfsqltype="CF_SQL_INTEGER" null="#arguments.rebateData.aComp[n].ParentProgramRebatesComponentID EQ 0 OR NOT IsNumeric(arguments.rebateData.aComp[n].ParentProgramRebatesComponentID)#">,
						<cfqueryparam value="#iTxtPercentage#" cfsqltype="CF_SQL_VARCHAR" null = "#isPercentNull#">
						,<cfqueryparam value="#arguments.rebateData.aComp[n].DontCountVolume#" cfsqltype="CF_SQL_BIT"> /* 79614 */
						,<cfqueryparam value="#arguments.rebateData.aComp[n].Blended_Rate_from_date#" cfsqltype="CF_SQL_DATE">---62343 8.0 - Blended Rate, CF
						,<cfqueryparam value="#arguments.rebateData.aComp[n].Blended_Rate_to_date#" cfsqltype="CF_SQL_DATE">---62343 8.0 - Blended Rate, CF
						,<cfqueryparam value="#arguments.rebateData.aComp[n].CompRate#" cfsqltype="CF_SQL_VARCHAR">---65711
						,<cfqueryparam value="#arguments.rebateData.aComp[n].CompUOM#" cfsqltype="CF_SQL_INTEGER">---65711
						)
					END
				</cfquery>

				<cfif isDefined("qInsertComps.Program_Rebates_Component_ID")>
					<cfset aTmpHolder[n] = qInsertComps.Program_Rebates_Component_ID />
				<cfelse>
					<!--- If qInsertComps did not insert the record qInsertComps.Program_Rebates_Component_ID will not be available, so do query --->
					<cfquery name="qGetComp" datasource="#application.datasource#">
						SELECT 	Program_Rebates_Component_ID
						FROM 	Program_Rebates_Component C
						WHERE 	C.Program_ID = <cfqueryparam value="#arguments.rebateData.programId#" cfsqltype="CF_SQL_INTEGER">
						AND		C.Program_Rebates_Component_Name_ID = <cfqueryparam value="#arguments.rebateData.aComp[n].compNameId#" cfsqltype="CF_SQL_INTEGER">
						AND		C.Component_Paid_To = <cfqueryparam value="#arguments.rebateData.aComp[n].componentPaidTo#" cfsqltype="CF_SQL_INTEGER">
						AND		C.Deleted = 0
					</cfquery>
					<cfset aTmpHolder[n] = qGetComp.Program_Rebates_Component_ID />
				</cfif>

				<!------ update discount type payment cycle ----->
				<!---<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
				 <cfset appSettings = genSettingsManager.get()> --->
				<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
				<cfif appSettings.getPaymentCycleAtDiscountType() AND len(trim(arguments.rebateData.aComp[n].PaymentCycle))>
					<cfset paymentCycleManager = CreateObject("component", "components.programs.PaymentCycleManager").init() />
					<cfset paymentCycleManager.savePaymentCycle(arguments.rebateData.programId, 2, arguments.rebateData.aComp[n].PaymentCycle,aTmpHolder[n]) />
				</cfif>

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
					SELECT DISTINCT  /* 112232 - Avoid duplicates */
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
					<!---
					There is a scenario where we are having duplicates in Program_Rebates_Component, Contract_Products.
					Could be due to double click or page reload by user, but we are not able to recreate.
					As we already did a DELETE just before, Contract_Products should not have an entry.
					Check if there are any records before inserting, to avoid duplication due to double click or page reload.
					--->
					WHERE	NOT EXISTS (
						SELECT 	1
						FROM 	Contract_Products cp
						WHERE 	cp.Contract_Main_ID = '#arguments.rebateData.programId#'
						AND		cp.BSA_Foodservice_Items_Master_ID = Tmp.masterItemID
						AND		cp.Product_Type_ID = 2
						AND		cp.Deleted = 0
					)
					/* ORDER BY pricingLevel,item ASC */
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
							CP.DELETED = 0  AND
							NOT EXISTS ( <!----- To avoid duplication --->
							SELECT	1
							FROM	Program_Rebates_Product_Data pd
							WHERE	pd.Program_ID = CP.Contract_Main_ID
							AND		pd.Contract_Products_ID = CP.Contract_Products_ID
							AND		pd.Deleted = 0
						)
					order by contract_products_id desc
				</cfquery>

				<cfquery name="qGetRebateProdData" datasource="#application.datasource#">
					SELECT	CP.BSA_Foodservice_Items_Master_ID, CP.Contract_Products_ID, PD.Program_Rebates_Product_Data_ID
					FROM 	Contract_Products CP
					INNER JOIN Program_Rebates_Product_Data PD
					ON		PD.Contract_Products_ID = CP.Contract_Products_ID
					AND		PD.Deleted = 0
					WHERE 	CP.Contract_Main_ID = '#arguments.rebateData.programId#' AND
							CP.Product_Type_ID = 2 AND
							CP.DELETED = 0
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

				<!--- Get Program_Rebates_Product_Data_ID --->
				<cfset useLakebaseForqGetRebateProdDataID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetrebateproddata")>
<cfif useLakebaseForqGetRebateProdDataID>
	<cftry>
		<cfset qGetRebateProdDataID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetrebateproddata", {
				"bsa_foodservice_items_master_id" = "eq.#arguments.rebateData.aProd[i].MASTERITEMID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetRebateProdDataID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetRebateProdDataID>
<cfquery name="qGetRebateProdDataID" dbtype="query">
					SELECT	*
					FROM 	qGetRebateProdData
					WHERE	BSA_Foodservice_Items_Master_ID = '#arguments.rebateData.aProd[i].MASTERITEMID#'
				</cfquery>
</cfif>
				<cfset Current_Program_Rebates_Product_Data_ID = qGetRebateProdDataID.Program_Rebates_Product_Data_ID />
				<cfset Current_Contract_Products_ID = qGetRebateProdDataID.Contract_Products_ID />

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
							<cfset arguments.rebateData.aCompVal[i][n].rate = Replace(arguments.rebateData.aCompVal[i][n].rate, "(", "-") >
							<cfset arguments.rebateData.aCompVal[i][n].rate = Replace(arguments.rebateData.aCompVal[i][n].rate, ")", "") >
						</cfif>

						<cfif Not isNumeric(arguments.rebateData.aCompVal[i][n].effectMarginPercent) OR arguments.rebateData.aComp[n].EffectiveMarginFlag EQ 0 >
							<cfset arguments.rebateData.aCompVal[i][n].effectMarginPercent = 100 />
						</cfif>

						<cfset rate = arguments.rebateData.aCompVal[i][n].rate />
						<cfset uomId = arguments.rebateData.aCompVal[i][n].uomId />
						<!--- if the uomID is null or 0 then grab the value from the template --->
						<cfif ((uomId EQ "" OR uomId EQ 0) AND (arguments.rebateData.programId NEQ ""))>
							<cfset qryUOM = getUOMfromTemplate(arguments.rebateData.programId) />
							<cfset arguments.rebateData.aCompVal[i][n].uomId = qryUOM.rateTypeDefault />
							<cfset uomId = arguments.rebateData.aCompVal[i][n].uomId />
						</cfif>
						<!----- for scan components if the uom selected by the user is "each", we store the rate entered by the user in the scan rate field
						and will store the rate converted to product UOM in the regular rate fields so that we do not have to change the rest of the application for now.
						once we have logic to handle uom="each" in other parts of the app we can remove the following conversion.

						if rebate type = Variable/Fixed Combo and uom=EA
						----->
						 <cfif arguments.rebateData.aCompVal[i][n].uomId eq 5 OR arguments.rebateData.aCompVal[i][n].uomId eq 7>
							<cfset arguments.rebateData.aCompVal[i][n].UserSelectedUoM = arguments.rebateData.aCompVal[i][n].uomId />
						 	<cfset uomId = 1 />

						 	<cfif arguments.rebateData.aCompVal[i][n].uomId eq 5>
								<cfset rate = arguments.rebateData.aCompVal[i][n].rate * arguments.rebateData.aProd[i].EAConversion />
							<cfelse>
								<cfset rate = arguments.rebateData.aCompVal[i][n].rate * arguments.rebateData.aProd[i].Sleeves_Per_Case />
							</cfif>

							<cfif arguments.rebateData.aProd[i].productInventoryUOM EQ "LB">
								<cfset uomId = 2 />
								<cfset rate = rate / arguments.rebateData.aProd[i].netWeight />
							 </cfif>
						 </cfif>
						<!--- -When we use the "% of list price" feature (48146 and 73058 and 73241).Do it for the newly added component only (val(arguments.rebateData.aCompVal[i][n].compid) eq 0).
						Without it, the previously added component's rate will change as well, which is not correct.--->
						 <cfif ((appSettings.get_Setting('Percentage_Of_List_Price') EQ '1') AND (GetTemplateInfoListPrice.Percentage_Of_List_Price EQ '1') AND (isDefined("FORM.txtPercentage")))>
							<cfif val(arguments.rebateData.aCompVal[i][n].compid) eq 0>
								<cfif len(FORM.txtPercentage) neq 0>
									<cfif (uomId EQ 1)>
										<cfset rate = (arguments.rebateData.aProd[i].Price_CS_DEL * FORM.txtPercentage)/100 />
									<cfelseif(uomId EQ 2)>
										<cfset rate = (arguments.rebateData.aProd[i].Price_LB_DEL * FORM.txtPercentage)/100 />
									</cfif>
								</cfif>
							</cfif>
						 </cfif>

						<cfif Current_Program_Rebates_Product_Data_ID neq "">
						<!--- UPDATE	Program_Rebates_Product_Data LABEL D28445 --->
						<cfset this.updRebateProductData(	arguments.rebateData.programId,
															Current_Program_Rebates_Product_Data_ID,
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
								,Blended_Base_Rate
								,Blended_Disc_Rate
								,Blended_Calc_Rate
								,Blended_Adj_Rate
								,User_picked_UOM
								)
							VALUES
								(
								'#aTmpHolder[n]#',
								'#Current_Program_Rebates_Product_Data_ID#',
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
								,<cfqueryparam value="#arguments.rebateData.aProd[i].Blended_Base_Rate#" cfsqltype="CF_SQL_FLOAT" null="#LEN(arguments.rebateData.aProd[i].Blended_Base_Rate) EQ 0#">
								,<cfqueryparam value="#arguments.rebateData.aProd[i].Blended_Disc_Rate#" cfsqltype="CF_SQL_FLOAT" null="#LEN(arguments.rebateData.aProd[i].Blended_Disc_Rate) EQ 0#">
								,<cfqueryparam value="#arguments.rebateData.aProd[i].Blended_Calc_Rate#" cfsqltype="CF_SQL_FLOAT" null="#LEN(arguments.rebateData.aProd[i].Blended_Calc_Rate) EQ 0#">
								<cfif arguments.rebateData.aProd[i].Blended_Adj_Rate GTE 0>
								,<cfqueryparam value="#arguments.rebateData.aProd[i].Blended_Adj_Rate#" cfsqltype="CF_SQL_FLOAT" >
								<cfelse>
								,<cfqueryparam value="#arguments.rebateData.aProd[i].Blended_Adj_Rate#" cfsqltype="CF_SQL_FLOAT" null="true" >
								</cfif>
								,<cfqueryparam value="#arguments.rebateData.aCompVal[i][n].UserSelectedUoM#" cfsqltype="CF_SQL_FLOAT" null="#IsNumeric(arguments.rebateData.aCompVal[i][n].UserSelectedUoM) EQ 0#">
								)
						</cfquery>


						<cfif arguments.rebateData.aComp[n].Alternate_Recapture_Rate neq "" and arguments.rebateData.aComp[n].Alternate_Recapture_Rate neq 0>

							<cfset this.InsertAlternateRates(arguments.rebateData.aComp[n].CompNameID,
														aTmpHolder[n],
														arguments.rebateData.programId,
														Current_Contract_Products_ID,
														arguments.rebateData.aCompVal[i][n].ar_rate,
														arguments.rebateData.aCompVal[i][n].ar_uom,
														arguments.rebateData.aCompVal[i][n].rate,
														arguments.rebateData.aCompVal[i][n].uomId) />
						</cfif>
						</cfif> <!--- <cfif Current_Program_Rebates_Product_Data_ID neq ""> --->


					</cfif>
				</cfloop>
			</cfloop>


			<cfquery name="qInsertCompData" datasource="#application.datasource#">
					INSERT INTO 	Program_Rebates_Component_Data	(
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
									,Blended_Base_Rate
									,Blended_Disc_Rate
									,Blended_Calc_Rate
									,Blended_Adj_Rate
									,User_picked_UOM
									)
					SELECT DISTINCT  /* 112232 - Avoid duplicates */
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
							,Blended_Base_Rate
							,Blended_Disc_Rate
							,Blended_Calc_Rate
							,Blended_Adj_Rate
							,User_picked_UOM
					FROM ##TMP_Program_Rebates_Component_Data Tmp
					WHERE	NOT EXISTS ( <!----- To avoid duplication --->
							SELECT	1
							FROM	Program_Rebates_Component_Data cd
							WHERE	cd.Program_Rebates_Component_ID = Tmp.Program_Rebates_Component_ID
							AND		cd.Program_Rebates_Product_Data_ID = Tmp.Program_Rebates_Product_Data_ID
							AND		cd.Deleted = 0
						)
				</cfquery>


			<cfif allProductSelected>
				<cfset ProductGroupManager.updateOtherAvgProductVolume(arguments.rebateData.programId) />
			</cfif>

			<!---check for revision--->
			<cfset useLakebaseForqCheckIfRevision = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqCheckIfRevision>
	<cftry>
		<cfset qCheckIfRevision = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"deleted" = "eq.0",
				"contract_main_id" = "eq.#arguments.rebateData.programId#",
				"select" = "is_a_revision"
			}), "is_a_revision"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckIfRevision = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckIfRevision>
<cfquery name="qCheckIfRevision" datasource="#application.datasource#">
				SELECT	Is_A_Revision
				FROM 	Contract_Main
				WHERE	Deleted = 0
				AND		Contract_Main_ID = #arguments.rebateData.programId#
			</cfquery>
</cfif>

			<!---check if it's a bid request--->
			<cfset useLakebaseForqCheckIfBidRequest = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bid_request")>
<cfif useLakebaseForqCheckIfBidRequest>
	<cftry>
		<cfset qCheckIfBidRequest = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_bid_request", {
				"deleted" = "eq.0",
				"program_id" = "eq.#arguments.rebateData.programId#",
				"select" = "program_id"
			}), "program_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckIfBidRequest = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckIfBidRequest>
<cfquery name="qCheckIfBidRequest" datasource="#application.datasource#">
				SELECT	Program_ID
				FROM 	Program_Bid_Request
				WHERE	Deleted = 0
				AND		Program_ID = #arguments.rebateData.programId#
			</cfquery>
</cfif>

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
			<cfelseif isDefined("arguments.dontCallSP") and arguments.dontCallSP neq 1>	<!---31869 - do not call when program has product groups as it would wipe out entered volume information for product members--->
				<cfstoredproc procedure="PROGRAM_PRODUCT_VOLUME_UPD" datasource="#application.datasource#">
					<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#arguments.rebateData.programId#" null="no">
				</cfstoredproc>


			<!---call SP to update program contract quantity --->
			<cfstoredproc procedure="Update_Program_Volume" datasource="#application.datasource#">

				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#arguments.rebateData.programId#" null="no">

			</cfstoredproc>

			</cfif>


		<!--- 62343 8.0 - Blended Rate, CF START--->
		<cfif appSettings.get_Setting('Blended_Rate') eq '1'>
			<cfquery name="BlendedRateOn" datasource="#application.datasource#">
				SELECT CASE WHEN PRCN.rebate_type = 7 THEN 1 ELSE 0 END AS Blended_Rate_On, PRC.Calculation_Period_Start, PRC.Calculation_Period_End
				FROM dbo.Program_Rebates_Component PRC
				INNER JOIN dbo.Program_Rebates_Component_Name PRCN
				ON PRCN.Program_Rebates_Component_Name_ID = PRC.Program_Rebates_Component_Name_ID
				WHERE PRC.Program_ID = #arguments.rebateData.programId#
				AND PRCN.Deleted = 0
				AND PRC.Deleted = 0
			</cfquery>

			<cfif BlendedRateOn.Blended_Rate_On EQ 1>
				<cfset BlendedRateVolume (arguments.rebateData.programId, BlendedRateOn.Calculation_Period_Start, BlendedRateOn.Calculation_Period_End, 1, bHasGroups)>
			</cfif>
		</cfif>
		<!--- 62343 8.0 - Blended Rate, CF END--->




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

		<cfif arguments.pricingLevelId gt 0 and pricingLevelId lte request.AccessStructure.numberOfProductGroupLevels>
			<cfset this.stRebate.aGroupLevel[arguments.pricingLevelId] = arguments.groupLevelId />
		</cfif>

	</cffunction>

	<cffunction name="initialiseGroupLevel" output="false">
		<cfset this.stRebate.aGroupLevel = ArrayNew(1) />
		<!---77408 Product Group sequencing START--->
				<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
						<cfset this.stRebate.aGroupLevel[#levels#] = "" />
				</cfloop>
		<!---77408 Product Group sequencing END--->
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
					 WHERE Contract_Products_Id	= '#conProdId#')
		</cfquery>
		<cfquery name="qDelRebateProduct2" datasource="#application.datasource#">
			--DELETE
			--FROM
			UPDATE Program_Rebates_Product_Data
			SET DELETED = 1
			WHERE Contract_Products_Id	= '#conProdId#'
		</cfquery>
			<!--- Dev Note: drachala;	D27947: Deleted Product Groups and Capture START --->
			<cfset useLakebaseForqIsGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForqIsGroup>
	<cftry>
		<cfset qIsGroup = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"contract_products_id" = "eq.#conProdId#",
				"select" = "is_group,product_group_id,product_type_id,contract_main_id,pricing_level_id"
			}), "is_group,product_group_id,product_type_id,contract_main_id,pricing_level_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqIsGroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqIsGroup>
<cfquery name="qIsGroup" datasource="#application.datasource#">
			SELECT is_group,Product_group_id,Product_Type_ID, contract_main_id,Pricing_Level_ID
			FROM Contract_Products
			WHERE contract_Products_Id	= '#conProdId#'
			</cfquery>
</cfif>
			<!--- Dev Note: drachala;	D27947: Deleted Product Groups and Capture END --->

		<cfquery name="qDelRebateProduct3" datasource="#application.datasource#">
			--DELETE
			--FROM
			UPDATE Contract_Products
			SET DELETED = 1
			<!--- Dev Note: drachala;	D27947: Deleted Product Groups and Capture START --->
			<cfif qIsGroup.is_group>
				WHERE Contract_Main_ID = #qIsGroup.contract_main_id#
				AND Product_group_id = '#qIsGroup.Product_group_id#'
				AND Product_Type_ID = #qIsGroup.Product_Type_ID#
				AND Deleted = 0
			<cfelse>
			WHERE Contract_Products_Id	= '#conProdId#'
			</cfif>
			<!--- Dev Note: drachala;	D27947: Deleted Product Groups and Capture END --->
		</cfquery>

	<!---77408 Product Group sequencing START--->
	<cfif request.AccessStructure.numberOfProductGroupLevels GT 3>
		<cfset useLakebaseForcheck4Levels = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForcheck4Levels>
	<cftry>
		<cfset check4Levels = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"pricing_level_id" = "eq.#qIsGroup.Pricing_Level_ID#",
				"contract_main_id" = "eq.#qIsGroup.contract_main_id#",
				"product_type_id" = "eq.2",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheck4Levels = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheck4Levels>
<cfquery name="check4Levels" datasource="#application.datasource#">
			SELECT *
			FROM Contract_Products
			WHERE Pricing_Level_ID	= #qIsGroup.Pricing_Level_ID#
			AND contract_main_id = #qIsGroup.contract_main_id#
			AND Product_Type_ID = 2
			AND Deleted = 0
		</cfquery>
</cfif>
		<cfif check4Levels.recordcount EQ 0>
			<cfquery name="updateLowLevels" datasource="#application.datasource#">
				<cfloop from ="#qIsGroup.Pricing_Level_ID#" to="8" index="levels">
					UPDATE Contract_Products
					SET Pricing_Level_ID = #levels#
					WHERE Pricing_Level_ID	= #levels# + 1
					AND contract_main_id = #qIsGroup.contract_main_id#
					AND Product_Type_ID = 2
					AND Deleted = 0
				</cfloop>
			</cfquery>
		</cfif>
	</cfif>
	<!---77408 Product Group sequencing END--->

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

		<!---call SP to update program contract quantity --->
		<cfstoredproc procedure="Update_Program_Volume" datasource="#application.datasource#">

			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#getProgID.Contract_Main_ID#" null="no">

		</cfstoredproc>

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
					 WHERE Contract_Products_Id	= '#conProdId#')
		</cfquery>
		<cfquery name="qUnDelRebateProduct2" datasource="#application.datasource#">
			--DELETE
			--FROM
			UPDATE Program_Rebates_Product_Data
			SET DELETED = 0
			WHERE Contract_Products_Id	= '#conProdId#'
		</cfquery>

		<cfquery name="qUnDelRebateProduct3" datasource="#application.datasource#">
			--DELETE
			--FROM
			UPDATE Contract_Products
			SET DELETED = 0
			WHERE Contract_Products_Id	= '#conProdId#'
		</cfquery>

		<cfquery name="getProgID" datasource="#application.datasource#">
		 SELECT Contract_Main_ID, Pricing_Level_ID,  Product_Group_Level_ID
		 FROM Contract_Products
		 WHERE Contract_Products_ID = '#conProdId#'
		</cfquery>

<!---77408 Product Group sequencing START--->
<cfif request.AccessStructure.numberOfProductGroupLevels GT 3>
			<cfquery name="check4Levels" datasource="#application.datasource#">
					SELECT *
					FROM Contract_Products
					WHERE Pricing_Level_ID	= #getProgID.Pricing_Level_ID#
					AND contract_main_id = #getProgID.contract_main_id#
					AND Product_Group_Level_ID  <> #getProgID.Product_Group_Level_ID#
					AND Product_Type_ID = 2
					AND Deleted = 0
			</cfquery>

			<cfif check4Levels.recordcount>
								<cfquery name="updateLowLevels" datasource="#application.datasource#">
										<cfloop to ="#getProgID.Pricing_Level_ID#" from="8" index="levels" step="-1">
												UPDATE Contract_Products
												SET Pricing_Level_ID = #levels#+1
												WHERE Pricing_Level_ID	= #levels#
												AND contract_main_id = #getProgID.contract_main_id#
												AND Product_Group_Level_ID  <> #getProgID.Product_Group_Level_ID#
												AND Product_Type_ID = 2
												AND Deleted = 0
										</cfloop>
								</cfquery>
			</cfif>
</cfif>
<!---77408 Product Group sequencing END--->

		<!---call SP to update program contract quantity --->
		<cfstoredproc procedure="Update_Program_Volume" datasource="#application.datasource#">

			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#getProgID.Contract_Main_ID#" null="no">

		</cfstoredproc>
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

	<cffunction Name="deleteAllProductsFromProgram" access="public" output="false" returntype="Array">
		<!--- 27063 - CF 9 puts the passing Ajax array argument in position 2, CF 8 puts in position 1!!
			Replaced the hard-coded of arguments[1] with a call to getArrayArgument() to find
			the array data needed to process --->
		<cfset var argArray = getArrayArgument( arguments ) />
		<cfset var programId 	= argArray[1] />
		<cfset var action 		= argArray[2] />
		<cfset var bAutoAddComponent = argArray[3] />
		<cfset var retArray 	= arrayNew(1) />
		<cfquery name="qDropTempTable" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_getDeleteCPList') IS NOT NULL
		 	DROP TABLE ##tmp_getDeleteCPList
			IF OBJECT_ID('tempdb..##tmp_getDeletePRPDList') IS NOT NULL
		 	DROP TABLE ##tmp_getDeletePRPDList
		</cfquery>
		<cfquery name="qGetContractProducts" datasource="#application.datasource#">
			SELECT	Contract_Products_ID
			INTO	##tmp_getDeleteCPList
			FROM	Contract_Products
			WHERE	Contract_Main_ID = '#programId#'
			AND		Deleted = 0
			AND		Product_Type_ID = 2

			SELECT	Program_Rebates_Product_Data_ID
			INTO	##tmp_getDeletePRPDList
			FROM	Program_Rebates_Product_Data
			WHERE	EXISTS (SELECT 1 FROM ##tmp_getDeleteCPList t WHERE t.Contract_Products_ID = Program_Rebates_Product_Data.Contract_Products_ID)
			AND		Deleted = 0
		</cfquery>
		<cfquery name="qDelRebateProduct1" datasource="#application.datasource#">
			UPDATE 	Program_Rebates_Component_Data
			SET 	DELETED = 1
			WHERE	EXISTS (SELECT 1 FROM ##tmp_getDeletePRPDList t WHERE t.Program_Rebates_Product_Data_ID = Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID)
			AND		Deleted = 0
		</cfquery>
		<cfquery name="qDelRebateProduct2" datasource="#application.datasource#">
			UPDATE 	Program_Rebates_Product_Data
			SET 	DELETED = 1
			WHERE 	Program_Rebates_Product_Data_ID IN (SELECT Program_Rebates_Product_Data_ID FROM ##tmp_getDeletePRPDList)
		</cfquery>

		<cfquery name="qDelRebateProduct3" datasource="#application.datasource#">
			UPDATE 	Contract_Products
			SET 	DELETED = 1
			WHERE 	Contract_Products_ID IN (SELECT Contract_Products_ID FROM ##tmp_getDeleteCPList)
		</cfquery>

		<!---call SP to update program contract quantity --->
		<cfstoredproc procedure="Update_Program_Volume" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#programId#" null="no">
		</cfstoredproc>

		<!---
			28993/Anand Rao/28-Oct-2011
			Single component changes
		--->
		<cfif bAutoAddComponent EQ 1>
			<cfquery name="getProductpresent" datasource="#application.datasource#">
				SELECT 	PRCD.Program_Rebates_Product_Data_ID
				FROM 	Program_Rebates_Product_Data PRPD
				INNER JOIN Program_Rebates_Component_Data PRCD ON
						PRCD.Program_Rebates_Product_Data_ID = PRPD.Program_Rebates_Product_Data_ID
	 			WHERE 	PRPD.Program_ID = #programId#
				AND		PRPD.Deleted = 0
			</cfquery>
			<cfif getProductpresent.Recordcount EQ 0>
				<cfquery name="updPrgRebComp" datasource="#application.datasource#">
					UPDATE Program_Rebates_Component
					SET Deleted = 1
					WHERE Program_ID = #programId#
				</cfquery>
			</cfif>
		</cfif>
		<cfset retArray[1] = programId />
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
					,Calculation_Period_Start =<cfqueryparam value="#aComp.Blended_Start_Date#" cfsqltype="CF_SQL_DATE"> <!---62343	8.0 - Blended Rate, CF--->
					,Calculation_Period_End=<cfqueryparam value="#aComp.Blended_End_Date#" cfsqltype="CF_SQL_DATE"><!---62343	8.0 - Blended Rate, CF--->
					,Dont_Count_Volume =  <cfqueryparam value="#aComp.DontCountVolume#" cfsqltype="CF_SQL_INTEGER"><!--- 79614: Bid Templates - only count fixed price component --->
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

	<!---D38536	:: Alternate recapture rates per component START--->
		<cfset var alternaterecapturerate = argArray[14]/>
		<cfset var contract_products_id = argArray[15]/>
		<cfset ar_rate = argArray[16] />
		<cfset ar_uom = argArray[17] />
		<cfset compnameid = argArray[18] />
	 <!---D38536	:: Alternate recapture rates per component END	--->

	<!--- D38846 ::	Recapture changes START --->
	<cfif arraylen(argArray) GT 18 AND ArrayIsDefined(argArray, 19)>
			<cfset MassApply = argArray[19] />
	<cfelse>
			<cfset MassApply = 0>
	</cfif>
	<!--- D38846 ::	Recapture changes END--->
		<!--- 62343 8.0 - Blended Rate CF START --->
		<cfif appSettings.get_Setting('Blended_Rate') eq '1'>
			<cfset Blended_Base_Rate = argArray[20] />
			<cfset Blended_Disc_Rate = argArray[21] />
			<cfset Blended_Calc_Rate = argArray[22] />
			<cfset Blended_Adj_Rate = argArray[23] />
		</cfif>
		<!--- 62343 8.0 - Blended Rate CF END --->

	<cfif arraylen(argArray) GTE 24 AND ArrayIsDefined(argArray, 24)>
		<cfset UserSelectedUoM = argArray[24] /><!---63887 --->
	<cfelse>
		<cfset UserSelectedUoM = #uom#>
	</cfif>
		<cfif trim(rate) eq ''>
				<cfset rate = 0 />
		</cfif>

		<cfset prodCompId 	= argArray[3] />
		<cfquery name="getProgID" datasource="#application.datasource#">
			SELECT prc.Program_ID, prc.Program_Rebates_Component_ID, prcn.Rebate_type
			FROM Program_Rebates_Component_Data prcd
			INNER JOIN Program_Rebates_Component prc
			ON prcd.Program_Rebates_Component_ID = prc.Program_Rebates_Component_ID
			LEFT JOIN Program_Rebates_Component_Name prcn
			ON prcn.Program_Rebates_Component_Name_ID = prc.Program_Rebates_Component_Name_ID
			AND prcn.Deleted =0
			WHERE prcd.Program_Rebates_Component_Data_ID = '#prodCompId#'
		</cfquery>

		<!--- 62343 8.0 -Blended Rate, CF START --->
              <cfif appSettings.get_Setting('Blended_Rate') eq '1' AND getProgID.Rebate_type EQ 7>
                  <cfif len(Blended_Adj_Rate)>
                      <cfset rate = #Blended_Adj_Rate#>
                  <cfelse>
                      <cfset rate = #Blended_Calc_Rate#>
                  </cfif>
              </cfif>
		<!----62343 8.0 -Blended Rate, CF END --->
		<cfif appSettings.get_Setting('Blended_Rate') eq '1' AND len(Blended_Calc_Rate) EQ 0>
			<cfset Blended_Calc_Rate = '0.0000'>
		</cfif>
		<cfquery name="qUpdRebateProduct" datasource="#application.datasource#">
			UPDATE	Program_Rebates_Component_Data
				SET		Rate = '#rate#',
						Unit_Of_Measure_ID = '#uom#'
					<cfif argSaveScanVolume>
					,Scan_Rate = <cfqueryparam value="#scanRate#" cfsqltype="cf_sql_float" null="#scanRate EQ 0 OR IsNumeric(scanRate) EQ 0#">
					,Scan_UOM =	<cfqueryparam value="#scanUom#" cfsqltype="cf_sql_integer" null="#scanRate EQ 0 OR IsNumeric(scanRate) EQ 0#">
					,Scan_Volume = <cfqueryparam value="#scanVolume#" cfsqltype="cf_sql_decimal" null="#scanVolume EQ 0 OR IsNumeric(scanVolume) EQ 0#">
					</cfif>
					,Program_Rebates_Component_Rule_ID = '#ruleId#'
					----62343 8.0 - Blended Rate, CF START
					<cfif appSettings.get_Setting('Blended_Rate') eq '1'>
						,Blended_Base_Rate = '#Blended_Base_Rate#'
						,Blended_Disc_Rate = '#Blended_Disc_Rate#'
						,Blended_Calc_Rate = '#Blended_Calc_Rate#'
						,Blended_Adj_Rate  = <cfif len(Blended_Adj_Rate)>'#Blended_Adj_Rate#' <cfelse>NULL</cfif>
					</cfif>
					----62343 8.0 - Blended Rate, CF END
					,User_Picked_UOM = #UserSelectedUoM#---63887
			OUTPUT INSERTED.Program_Rebates_Product_Data_ID
			WHERE	Program_Rebates_Component_Data_ID = '#prodCompId#'
		</cfquery>

		<!--- UPDATE	Program_Rebates_Product_Data LABEL D28445 --->
			<cfset this.updRebateProductData(	getProgID.Program_ID,
												qUpdRebateProduct.Program_Rebates_Product_Data_ID,
												Competitor_Price,
												Competitor_Name_ID,
												Competitor_Time_Frame,
												CompetitorSourceOther) />
			<!--- D38846 ::	Recapture changes START-
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
				<!---D38536	:: Alternate recapture rates per component START --->
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
				<!---D38536	:: Alternate recapture rates per component END --->
			<!---</cfif>
			 D38846 ::	Recapture changes END--->

		<cfreturn argArray />
	</cffunction>

	<cffunction name="getArrayArgument" output="false" hint="Returns the first array argument in the arguments structure.">
	<cfscript>
		var idx = 0;
		// search for array in the passing argument (note: arguments is an array of an array)
		for ( idx=1;	idx LTE ArrayLen(arguments[ 1 ]);	idx=idx+1 ) {
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
		<cfset var Sleeves_Per_Case 	= '' />
		<cfset var NetWeight 	= 0 />
		<cfset var productInventoryUOM 	= '' />
		<cfset var Competitor_Price		= '' />
		<cfset var Competitor_Name_ID	= '' />
		<cfset var Competitor_Time_Frame	= '' />
		<cfset var CompetitorSourceOther	= '' />
		<!---D38536	:: Alternate recapture rates per component	START--->
		<cfset var ArratesCount= '' />
		<cfset var ArRates= '' />
		<cfset var ArUOM= ''/>
		<cfset var prodID='' />
		<cfset var CompNameID='' />
		<cfset var CompID='' />
		<!---D38536	:: Alternate recapture rates per component END --->
		<cfset var UserSelectedUoM 			= '' /><!---63887 --->
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
			<cfset Sleeves_Per_Case	= argArray[x][22] />
			<cfset NetWeight	= argArray[x][21] />
			<cfset productInventoryUOM	= argArray[x][9] />
			<cfset Competitor_Name_ID	= argArray[x][10] />
			<cfset Competitor_Price		= argArray[x][11] />
			<cfset Competitor_Time_Frame = argArray[x][12] />
			<cfset CompetitorSourceOther = argArray[x][13] />
			<!---D38536	:: Alternate recapture rates per component	START--->
			<cfscript>
				ArratesCount = 0;
				ArRates      = [];
				ArUOM        = '';
				ProdID       = '';
				CompNameID   = '';
				CompID       = '';
			</cfscript>
			<cfif arrayLen(argArray[x]) gte 14>
				<cfset ArratesCount	= argArray[x][14] />
				<cfset ArRates      = argArray[x][15] />
				<cfset ArUOM        = argArray[x][16] />
				<cfset ProdID       = argArray[x][17] />
				<cfset CompNameID   = argArray[x][18] />
				<cfset CompID       = argArray[x][19] />
			</cfif>
			<!---D38536	:: Alternate recapture rates per component	END--->
			<cfif trim(rate) eq ''>
				<cfset rate = 0 />
			</cfif>

			<cfif arrayLen(argArray[x]) gte 20>
				<cfset UserSelectedUoM	= argArray[x][20] /><!---63887 --->
			<cfelse>
				<cfset UserSelectedUoM	= 0 />
			</cfif>

			<!---
			for scan components if the uom selected by the user is "each", we store the rate entered by the user in the scan rate field
			and will store the rate converted to product UOM in the regular rate fields so that we do not have to change the rest of the application for now.
			once we have logic to handle uom="each" in other parts of the app we can remove the following conversion.

			if rebate type = Variable/Fixed Combo and uom=EA
			--->
			<cfset scanRate = rate />
			<cfset scanUom = uom />
			<cfif uom eq 5 OR uom eq 7>
				<cfset UserSelectedUoM	= uom />
			 	<cfset uom = 1 />
			 	<cfif uom eq 5 >
					<cfset rate = rate * EAConversion />
				<cfelse>
					<cfset rate = rate * Sleeves_Per_Case />
			 	</cfif>
				<cfif productInventoryUOM EQ "LB">
					<cfset uom = 2 />
					<cfset rate = rate / NetWeight />
				</cfif>
			</cfif>

			<cfquery name="qUpdRebateProduct" datasource="#application.datasource#" result="qUpd">
				UPDATE	Program_Rebates_Component_Data
				SET		Rate = '#rate#',
						Unit_Of_Measure_ID = '#uom#',
						Scan_Rate = <cfqueryparam value="#scanRate#" cfsqltype="cf_sql_float" null="#scanRate EQ 0 OR IsNumeric(scanRate) EQ 0#">,
						scan_Uom =	<cfqueryparam value="#scanUom#" cfsqltype="cf_sql_integer" null="#scanRate EQ 0 OR IsNumeric(scanRate) EQ 0#">,
						Scan_Volume = <cfqueryparam value="#scanVolume#" cfsqltype="CF_SQL_DECIMAL" null="#scanVolume EQ 0 OR IsNumeric(scanVolume) EQ 0#">
						,User_Picked_UOM = <cfqueryparam value="#UserSelectedUoM#" cfsqltype="cf_sql_integer" null="#UserSelectedUoM EQ 0 OR IsNumeric(UserSelectedUoM) EQ 0#"><!---63887 --->
				OUTPUT INSERTED.Program_Rebates_Product_Data_ID
				WHERE	Program_Rebates_Component_Data_ID = '#prodCompId#'
			</cfquery>
			<!--- UPDATE	Program_Rebates_Product_Data LABEL D28445 --->
			<cfset this.updRebateProductData(	getProgID.Program_ID,
												qUpdRebateProduct.Program_Rebates_Product_Data_ID,
												Competitor_Price,
												Competitor_Name_ID,
												Competitor_Time_Frame,
												CompetitorSourceOther) />

<!---D38536	:: Alternate recapture rates per component START 	 --->
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
<!---D38536	:: Alternate recapture rates per component END --->

		</cfloop>
		<!--- Dev Note - (79237) - For argArray[1][5], index of 1 means the first component, and index of 5 is the ProductID. Actually, productID will be the same for all the components,
		but here we are just using the first index to get the productID, we alll we want is the productID.
		Note: This function (saveProdRate_All) updates rates for all the comoonents for a SINGLE product.
		--->
		<cfset objPrgManager.updateSecondComponentRates(getProgID.Program_ID,2,argArray[1][5])>

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

			<cfquery name="checkGroupProgram" datasource="#application.datasource#">
				SELECT 1
				FROM Contract_Products
				WHERE Contract_MAIN_ID = '#arguments.ProgramID#'
				AND Is_Group = 1
				AND Deleted = 0
			</cfquery>

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
				SELECT IsNull(program_rebates_component_data.rate,0) As rate
				FROM program_Rebates_product_data
				INNER JOIN program_rebates_component_data
				ON program_Rebates_product_data.Program_Rebates_product_data_ID = program_rebates_component_data.program_Rebates_product_data_ID
				INNER JOIN program_Rebates_component
				ON program_rebates_component_data.program_Rebates_component_ID = program_Rebates_component.program_Rebates_component_ID
				INNER JOIN contract_products
				ON contract_products.contract_products_ID = program_Rebates_product_data.contract_products_ID
				WHERE program_Rebates_product_data.program_ID = '#arguments.Program_ID#'
				AND program_Rebates_product_data.deleted = 0
				AND program_Rebates_component.deleted = 0
				AND program_rebates_component_data.deleted = 0
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
						IsNull(program_rebates_component_data.rate,0) As Rate,
						program_rebates_component_data.Unit_Of_Measure_ID AS UOM
					FROM program_Rebates_product_data
					INNER JOIN program_rebates_component_data
					ON program_Rebates_product_data.Program_Rebates_product_data_ID = program_rebates_component_data.program_Rebates_product_data_ID
					INNER JOIN program_Rebates_component
					ON program_rebates_component_data.program_Rebates_component_ID = program_Rebates_component.program_Rebates_component_ID
					INNER JOIN contract_products
					ON contract_products.contract_products_ID = program_Rebates_product_data.contract_products_ID
					WHERE program_Rebates_product_data.program_ID = '#arguments.Program_ID#'
					AND program_Rebates_product_data.deleted = 0
					AND program_Rebates_component.deleted = 0
					AND program_rebates_component_data.deleted = 0
					AND contract_products.deleted = 0
					AND contract_products.BSA_Foodservice_Items_Master_ID= '#arguments.Product_ID#'
					AND program_Rebates_component.Program_Rebates_Component_Name_ID = '#arguments.Component_Name_ID#'
		<!--- Dev Note: drachala; D27521: HZPROD283	SARP PRG message . This value is greater than the template	START--->
	 				-- AND program_Rebates_component.Component_Paid_To = '#arguments.Paid_To#'
			<!--- Dev Note: drachala; D27521: HZPROD283	SARP PRG message . This value is greater than the template	END--->
			</cfquery>
	 </cfif>
	 <cfif (arguments.Program_ID EQ 0) OR (qryRebateProductComponentRate.RecordCount EQ 0)>
		<cfset qryRebateProductComponentRate = QueryNew("Rate, UOM")>
		<cfset newRow	= QueryAddRow(qryRebateProductComponentRate, 1)>
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

			<cfif appsettings.getUseFixedPriceType() && isNumeric(Competitor_Name_ID) >	<!---&& this.getfixedComponentType(Program_ID) GT 0--->
				<cfif Competitor_Name_ID EQ -1>
					<!--- see if "other" record exists --->
					<cfset useLakebaseForgetOtherWonBy = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bid_won_by")>
<cfif useLakebaseForgetOtherWonBy>
	<cftry>
		<cfset getOtherWonBy = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_bid_won_by", {
				"program_bid_won_by_description" = "eq.#CompetitorSourceOther#",
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
						SELECT Program_Bid_Won_By_Description,Program_Bid_Won_By_ID
						FROM	Program_Bid_Won_By
						WHERE Program_Bid_Won_By_Description = '#CompetitorSourceOther#'
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

    <!---D38536	:: ALTERNATE RECAPTURE RATES PER COMPONENT START --->
	<cffunction name="InsertAlternateRates">
		<cfargument name="Component_Name_ID" 	type="numeric" 		required="true" 		default="0">
		<cfargument name="Component_ID" 		type="numeric" 		required="true" 		default="0">
		<cfargument name="Contract_Main_ID" 	type="numeric" 		required="true" 		default="0">
		<cfargument name="Contract_Product_ID" 	type="numeric" 		required="true" 		default="0">
		<cfargument name="Ar_rate" 				type="array" 		required="true" 		default="arraynew(1)">
		<cfargument name="Ar_uom" 				type="array" 		required="true" 		default="arraynew(1)">
		<cfargument name="rebRate"				type="numeric" 		required="false" 		default="0"	>
		<cfargument name="rebUOM"				type="numeric" 		required="false" 		default="0"	>

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
				AND Contract_Products_ID =	<cfqueryparam value="#arguments.Contract_Product_ID#" cfsqltype="cf_sql_integer" />
				AND Program_Rebates_Component_ID =	<cfqueryparam value="#arguments.Component_ID#" cfsqltype="cf_sql_integer" />
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
	</cffunction>

<!---D38536	:: ALTERNATE RECAPTURE RATES PER COMPONENT END --->
<!--- D38846 ::	Recapture changes START--->
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
		 						 WHERE Contract_Main_ID					= <cfqueryparam value="#local.Component.programID#" cfsqltype="cf_sql_integer" />
												AND Program_Rebates_Component_ID	 = <cfqueryparam value="#local.Component.compuuID#" cfsqltype="cf_sql_integer" />
												AND Contract_Products_ID			 = <cfqueryparam value="#local.Product.ContractProdID#" cfsqltype="cf_sql_integer" />
												AND Alternate_Recapture_Rate_Index = <cfqueryparam value="#local.alternate_recapture_index#" cfsqltype="cf_sql_integer" />

								INSERT INTO Program_Rebate_Alternate_Recapture_Rate
												(	 Program_Rebates_Component_ID
												, Contract_Main_ID
												, Contract_Products_ID
												, Alternate_Recapture_Rate_Index
												, Rate
												, UOM
												)
								 VALUES (	 <cfqueryparam value="#local.Component.compuuID#" cfsqltype="cf_sql_integer" />
													, <cfqueryparam value="#local.Component.programID#" cfsqltype="cf_sql_integer" />
													, <cfqueryparam value="#local.Product.ContractProdID#" cfsqltype="cf_sql_integer" />
													, <cfqueryparam value="#local.alternate_recapture_index#" cfsqltype="cf_sql_integer" />
													, #local.rate#
													, #arguments.thisForm.apply_uom#
												)
							</cfquery>
						</cfif>	<!--- StructKeyExists( arguments.ThisForm, "AR_MassApply_" & local.aComponent.CompNameID & local.alternate_recapture_index ) --->
					</cfloop>	<!--- from="1" to="#local.Component.alternate_recapture_rate#" index="local.alternate_recapture_index" --->
				</cfloop>	<!--- array="#arguments.stDataStructure.aComp#" index="local.Component" --->
			</cfif>	<!--- StructKeyExists(arguments.ThisForm, "prodChkBx_" & local.Product.MasterItemID --->
		</cfloop>	<!--- array="#arguments.stDataStructure.aProd#" index="local.Product" --->

	</cffunction>

<!--- D38846 ::	Recapture changes END--->
<cffunction name="dmp" >
		<cfargument name="x" type="any" required="true" default="">
		<!---<cfdump var="#x#" output="c:\dump.log">--->
	</cffunction>

<!--- D44174	Prod Event 643 - Routines cannot be declared more than once. The routine getBrandName has been declared twice in different templates START--->
	<cffunction name="getBrandName" output="true" returntype="string">
		<cfargument name="item_master_id"	required="true">
		<cfargument name="Brand_Query"	required="true" type="Query"	>
		<!--- gather brand information for a single item --->
		<cfquery name="local.qoqBrand" dbtype="query">
			SELECT Brand_Name
				FROM arguments.Brand_Query
			 WHERE BSA_Foodservice_Items_Master_ID = <cfoutput>'#arguments.item_master_id#'</cfoutput>
		</cfquery>

		<cfreturn local.qoqBrand.Brand_Name>
	</cffunction>
<!--- D44174	Prod Event 643 - Routines cannot be declared more than once. The routine getBrandName has been declared twice in different templates END--->
	<cffunction name="getSaveStatus" output="false" returntype="struct" access="remote" >
		<cfparam name="session.nRebateSaveProgress" default="0"/>
		<cfparam name="session.nRebateSaveMax" default ="1"/>
		<cfscript>
			var n = 0;
			/*if(session.nRebateSaveProgress > 0){
				n = session.nRebateSaveProgress/session.nRebateSaveMax;
			}*/
			n = session.nRebateSaveProgress;
			var s = n * 100;
			s = numberformat(s,'999');
			if(s == '100'){
				s = 'Please wait while the transaction is finalized.';
			}
			else{
				s = s & '%';
			}
			//writelog(file='application',text='#now()#  ::  #n#  :: #session.nRebateSaveProgress#  ::  #session.nRebateSaveMax#');
			var result = {};
			result.status = n;
			result.message= s;
			return result;
		</cfscript>

	</cffunction>
	<!---62343 8.0 - Blended Rate, CF START--->
	<cffunction name="BlendedRateVolume">
		<cfargument name="Program_ID" 	type="numeric" 		required="true" 		default="0">
		<cfargument name="FromDate" 	type="date" 		required="true" 		default="0">
		<cfargument name="ToDate" 		type="date" 		required="true" 		default="0">
		<cfargument name="ForceRun" 	type="numeric" 		required="false" 		default="0">
		<cfargument name="fromGroup"	type="numeric"	required="false" default="0">

		<cfif arguments.fromGroup>
			<cfstoredproc procedure="SP_CAPTURE_ALL_FOR_GROUPS" datasource="#application.datasource#">
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#arguments.Program_ID#" null="no">
				<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName = "@@Default_One_Case" value = "1" null="no">
				<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName = "@@From_EZ_Template" value = "0" null="no">
			</cfstoredproc>
		</cfif>

		<cfstoredproc procedure="Blended_Rate_Get_Volume" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@contract_main_Id" value = "#arguments.Program_ID#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_DATE" dbVarName = "@Start_Date" value = "#arguments.FromDate#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_DATE" dbVarName = "@End_Date" value = "#arguments.ToDate#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Recalc_All" value = "1" null="no">
		</cfstoredproc>

	</cffunction>

	<cffunction name="BlendedRateCalReport" output="true">
		<cfargument name="Program_ID"	type="numeric"	required="true">

		<cfquery name="BlendedCalReport" datasource="#application.datasource#">
			SELECT cm.Contract_Number, i.Item, i.Description,cd.Blended_Base_Rate, cd.Blended_Disc_Rate, cd.Blended_Adj_Rate, cd.Blended_Calc_Rate, cd.Rate,  UOM.Abbreviation_Singular,
			CASE
				WHEN cd.Unit_Of_Measure_ID = 2 THEN b.Invoice_Volume_LB
				WHEN cd.Unit_Of_Measure_ID > 2 AND PCPO.RateTypeDefault = 2 THEN b.Invoice_Volume_LB
				ELSE b.Invoice_Volume END AS Invoice_Volume,

			CASE
				WHEN cd.Unit_Of_Measure_ID = 2 THEN b.Recapture_Volume_LB
				WHEN cd.Unit_Of_Measure_ID > 2 AND PCPO.RateTypeDefault = 2 THEN b.Recapture_Volume_LB
				ELSE b.Recapture_Volume END AS Recapture_Volume,

			CASE
				WHEN cd.Unit_Of_Measure_ID = 2 THEN (b.Invoice_Volume_LB - b.Recapture_Volume_LB)
				WHEN cd.Unit_Of_Measure_ID > 2 AND PCPO.RateTypeDefault = 2 THEN (b.Invoice_Volume_LB - b.Recapture_Volume_LB)
				ELSE (b.Invoice_Volume - b.Recapture_Volume) END AS Base_Volume

				,iSNULL(GD.Group_Desc +' ( '+ GD.Group_Number + ' )','Individual Items') AS GroupDescription

			FROM   Contract_Main cm
			INNER JOIN Contract_Products cp
			ON	cp.Contract_Main_Id = cm.Contract_Main_Id
			AND	cp.Deleted = 0
			AND	cp.Product_Type_Id = 2
			AND	cp.Is_Group = 0
			INNER JOIN BSA_Foodservice_Items_Master i
			ON	i.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
			INNER JOIN Program_Blended_Rate_Info b
			ON	b.Program_ID = cp.Contract_Main_Id
			AND	b.Product_ID = cp.bsa_FoodService_Items_Master_Id
			INNER JOIN Program_Rebates_Product_Data pr
			ON	pr.Contract_Products_Id = cp.Contract_Products_Id
			AND	pr.Deleted = 0
      INNER JOIN Program_Rebates_Component_Data cd
      ON       cd.Program_Rebates_Product_Data_Id = pr.Program_Rebates_Product_Data_Id
      AND     cd.Deleted = 0
      INNER JOIN Program_Control_Panel_Options PCPO
      ON PCPO.ProgramControl_Panel_Options_ID = CM.programtype_id
      INNER JOIN Units_of_Measure UOM
      ON UOM.Unit_Of_Measure_ID =
                  CASE
                  WHEN cd.Unit_Of_Measure_ID = 2 THEN 2
                  WHEN cd.Unit_Of_Measure_ID > 2 AND PCPO.RateTypeDefault = 2 THEN 2
                  ELSE 1
                  END
				LEFT JOIN All_Product_Group_Types GD
				ON cast (GD.Group_GUID as varchar(50)) = CP.Product_Group_ID
      WHERE  cm.Contract_Main_Id = #arguments.Program_Id#
			Order By 1, 2, cp.Is_Group desc
		</cfquery>

		<cfreturn BlendedCalReport>
	</cffunction>
	<!---62343 8.0 - Blended Rate, CF END--->
  <!---48162 :: Create Product/Rate List ENHANCEMENT START---->
  <cffunction name="UpdatePricingLevel" output="true" returntype="numeric" hint="this function will update pricing level if upload data has only 1 product group level and items OR only items">
  	<cfargument name="tablename"	type="any"	required="true">
	<cfquery name="qUpdatePricingLevel" datasource="#application.datasource#">
		Declare @IsGroup INT = 0
		SELECT  @IsGroup = COUNT(DISTINCT Product_Group_Level_Id)
		FROM #arguments.tablename#
		WHERE Removed = 0
        	AND  UOM <> 'DEL'
		AND Product_Group_Level_Id NOT IN (0,9)

		IF @IsGroup = 1
			BEGIN
				UPDATE #arguments.tablename#
				SET Pricing_Level_Id = 1
				WHERE Removed = 0
				AND IsGroup = 1

				UPDATE #arguments.tablename#
				SET Pricing_Level_Id = 2
				WHERE Removed = 0
				AND IsGroup = 0
			END
		ELSE IF @IsGroup = 0
			BEGIN
				UPDATE #arguments.tablename#
				SET Pricing_Level_Id = 1
				WHERE Removed = 0
				AND IsGroup = 0
			END

		SELECT @IsGroup AS IsGroup
	</cfquery>
	<cfreturn qUpdatePricingLevel.IsGroup>
  </cffunction>

	<cffunction name="FinalUploadSave" output="false" hint="this function will insert uploaded data">
		<cfargument name="contract_main_id"	type="numeric"	required="true">
		<cfargument name="tablename"	    type="any"	    required="true">
		<cfargument name="productTypeID"	type="numeric"	required="true">

		<cfquery datasource="#application.datasource#">
			DECLARE @is_planner_program BIT
			DECLARE @is_direct_planner  BIT

			SELECT  @is_planner_program = 0
			      , @is_direct_planner  = 0

			SELECT  @is_planner_program = 1
					,@is_direct_planner = IIf( p.Parent_Planner_ID > 0, 0, 1 )
			  FROM  Contract_Main cm
					JOIN Planners p ON p.Planner_ID = cm.Planner_ID
			 WHERE  cm.Contract_Main_ID = #arguments.contract_main_id#
					AND cm.Planner_ID   > 0
			 		AND cm.Deleted      = 0

			EXEC Copy_Paste_Rebate_Data   @contract_main_id = #arguments.contract_main_id#
										, @tname            = '#arguments.tablename#'
										, @ProductTypeID    = #arguments.productTypeID#

			IF ( @is_planner_program = 1 ) BEGIN
				EXEC SP_CAPTURE_ALL_FOR_GROUPS #arguments.contract_main_id#

				IF ( @is_direct_planner = 1 ) BEGIN
					EXEC Planner_Program_Product_Volume_From_Volume_Plan #arguments.contract_main_id#
				END
			END
		</cfquery>
	</cffunction>

 <cffunction name="InsertUpdateRecords" output="false" hint="this function will records if they don't exist into temp table, if they exist they will update Rate/UOM">
 	<cfargument name="item"	type="any"	required="true">
 	<cfargument name="Rate"	type="any"	required="true">
 	<cfargument name="UOM"	type="any"	required="true">
 	<cfargument name="tablename"	type="any"	required="true">
   <cfargument name="CompID"  type="numeric"  required="true">
	<cfargument name="uom_validation" required="false" default="0">
	<cfargument name="getRateTypesFromTemplate" required="true">
	<cfargument name="CompVol" 	type="any"	required="false">

	<cfset useLakebaseForitem_GUID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_items_master")>
<cfif useLakebaseForitem_GUID>
	<cftry>
		<cfset item_GUID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_items_master", {
				"item" = "eq.#arguments.item#",
				"select" = "bsa_foodservice_items_master_id as bsa_id,0 as product_group_level_id"
			}), "bsa_foodservice_items_master_id as bsa_id,0 as product_group_level_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForitem_GUID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForitem_GUID>
<cfquery name="item_GUID" datasource="#application.datasource#">
		SELECT BSA_Foodservice_Items_Master_ID AS BSA_ID, 0 AS Product_Group_Level_ID
		FROM BSA_Foodservice_Items_Master
		WHERE item = '#arguments.item#'
	</cfquery>
</cfif>

	<cfif item_GUID.recordCount EQ 0>
		<cfquery name="item_GUID" datasource="#application.datasource#">
			SELECT APGT.Group_GUID AS BSA_ID, APGT.Product_Group_Level_ID
			FROM Program_Control_Panel_Options PCPO
			INNER JOIN Group_Template GT
			ON GT.Template_ID = PCPO.First_Parent_ID
			AND GT.Deleted = 0
			AND GT.PG_Group_Type  = 1
			INNER JOIN All_Product_Group_Types APGT
			ON APGT.Product_Group_Level_ID = GT.Group_Level_ID
			WHERE PCPO.ProgramControl_Panel_Options_ID = <cfif len(arguments.getRateTypesFromTemplate.ProgramControl_Panel_Options_ID)>#arguments.getRateTypesFromTemplate.ProgramControl_Panel_Options_ID#<cfelse>0</cfif>
			AND GT.Allow_In_Group_Search  = 1
			AND APGT.Group_Number =  '#arguments.item#'
			AND APGT.Deleted = 0
		</cfquery>
	</cfif>

<!--- if item does not exist in system --->
	<cfif item_GUID.recordCount EQ 0>
		<cfset itemGUID = '00000000-0000-0000-0000-000000000000'>
		<cfset productGroupLevelID = '0'>
	<cfelse>
		<cfset itemGUID = item_GUID.BSA_ID>
		<cfset productGroupLevelID = item_GUID.Product_Group_Level_ID>
	</cfif>

	<cfset local.uom_string = arguments.uom>
	<cfif arguments.UOM EQ 'CS'>
		<cfset UOM =1>
	<cfelseif arguments.UOM EQ 'LB' OR arguments.UOM EQ 'LBS'>
		<cfset UOM = 2>
	<cfelseif arguments.UOM EQ '%'>
		<cfset UOM = 3>
	<cfelseif arguments.UOM EQ 'CWT'>
		<cfset UOM = 6>
	<cfelseif arguments.UOM EQ 'EA' OR arguments.UOM EQ 'UN'>
		<cfset UOM = 5>
	<cfelseif arguments.UOM EQ 'SL'>
		<cfset UOM = 7>
	<cfelse>
		<cfset UOM = arguments.UOM>
	</cfif>

<cfset Duplicate = 0 />
<cfif itemGUID EQ '00000000-0000-0000-0000-000000000000'>
		<cfset reason = 'Invalid Item '>
		<cfset removed = 0>
		<cfset invalid = 1>
		<cfset valid = 0>
	<cfelseif ! IsNumeric(arguments.rate)>
		<cfset reason = 'Rate Formatting Error'>
		<cfset removed = 0>
		<cfset invalid = 1>
		<cfset valid = 0>
	<cfelseif arguments.UOM EQ 'DEL'>
		<cfset reason = 'Deleted Record'>
		<cfset removed = 1>
		<cfset invalid = 0>
		<cfset valid = 0>
	<cfelse>
		<cfset reason = ''>
		<cfset removed = 0>
		<cfset invalid = 0>
		<cfset valid = 1>
		<cfif arguments.uom_validation is "1">
			<cfset local.uom_exclusion = []>
			<!--- validate UOM against program template settings --->
			<cfif arguments.getRateTypesFromTemplate.RateTypeOption_2 eq 0>
				<cfset arrayAppend(local.uom_exclusion, 1)>
			</cfif>
			<cfif arguments.getRateTypesFromTemplate.RateTypeOption_1 eq 0>
				<cfset arrayAppend(local.uom_exclusion, 2)>
			</cfif>
			<cfif arguments.getRateTypesFromTemplate.RateTypeOption_3 eq 0>
				<cfset arrayAppend(local.uom_exclusion, 3)>
			</cfif>
			<!---63887 :: Need new UOM for Per Hundred Weight (CWT) START--->
			<cfif arguments.getRateTypesFromTemplate.RateTypeOption_4 eq 0>
				<cfset arrayAppend(local.uom_exclusion, 6)>
			</cfif>
			<cfif arguments.getRateTypesFromTemplate.RateTypeOption_5 eq 0>
				<cfset arrayAppend(local.uom_exclusion, 5)>
			</cfif>
			<cfif arguments.getRateTypesFromTemplate.RateTypeOption_6 eq 0>
				<cfset arrayAppend(local.uom_exclusion, 7)>
			</cfif>

			<cfif arrayFind(local.uom_exclusion, UOM)>
				<cfscript>
					reason  = uCase(local.uom_string) & " is not included in program template";
					invalid = 1;
					valid   = 0;
				</cfscript>
			</cfif>
		</cfif>
	</cfif>

	<cfquery name="local.checkExistingRecords" datasource="#application.datasource#">
		SELECT Count(*) AS TotalCount
		FROM #arguments.tablename#
		WHERE BSA_Foodservice_Items_Master_ID = '#trim(itemGUID)#'
		AND Comp_ID = #arguments.CompID#
	</cfquery>


	<cfif local.checkExistingRecords.TotalCount eq 0>
		<cfif arguments.UOM EQ 'DEL'>
			<cfset removed = 1 />
			<cfset invalid = 1 />
			<cfset Reason = 'Removed Item' />
		</cfif>
	<cfelseif local.checkExistingRecords.TotalCount GTE 0>
		<cfset Duplicate = 1 />
		<cfset Reason = 'Duplicate item' />
		<cfset removed = 1 />

		<cfquery datasource="#application.datasource#">
			UPDATE #arguments.tablename#
			  SET RATE = '#arguments.rate#',
			  	  UOM = '#UOM#'
			WHERE BSA_Foodservice_Items_Master_ID = '#trim(itemGUID)#'
			AND Comp_ID = #arguments.CompID#
		</cfquery>
	</cfif>


	<cfquery datasource="#application.datasource#">
		INSERT INTO #arguments.tablename#
			(	Program_Id,
				Comp_ID,
				BSA_Foodservice_Items_Master_ID,
				Products_ID,
				Rate,
				UOM,
				Reason,
				Invalid,
				Removed,
				Duplicate,
				Valid,
				Product_Group_Level_ID,
				Scan_Percentage	)
		VALUES
			(	#url.programId#,
				#arguments.CompID#	,
				'#trim(itemGUID)#',
				'#arguments.item#',
				'#trim(arguments.rate)#',
				'#uom#',
				'#reason#',
				#invalid#,
				#removed#,
				#Duplicate#,
				#valid#,
				#productGroupLevelID#,
				'#arguments.CompVol#'	)
		</cfquery>
 </cffunction>

  <cffunction name="ExistingRecordsReport" output="true" returntype="any" hint="this function used to download existing data or insert existing data into temp table.">
	<cfargument name="contract_main_id"	type="numeric"	required="true">
	<cfargument name="tablename"	type="any"	required="false">
	<cfargument name="ProductTypeID"	type="numeric"	required="false" default="0">
	<cfargument name="genratereport"	type="numeric"	required="false" default="0">

	<!--- WR 77502 Fixes for CWT issues when importing new Products   :: ADDED  PRCD.User_picked_UOM --->
	<cfquery name="qExisitingRebatedata" datasource="#application.datasource#" result="data">

	<cfif arguments.genratereport EQ 0>
		INSERT INTO #tablename# (Program_ID,Comp_ID,BSA_Foodservice_Items_Master_ID,Products_ID,Rate,UOM,Pricing_Level_Id,Product_Group_Level_Id,Valid,IsGroup,InDB,User_picked_UOM, Scan_Percentage)
	</cfif>

		SELECT	CP.Contract_Main_ID,
		PRC.Program_Rebates_Component_ID,
		ISNULL(CP.BSA_Foodservice_Items_Master_ID, PGT.Group_GUID) AS BSA_ID,
		BSA.Item,
		CAST(CAST(prcd.Rate as decimal(18,4)) AS VARCHAR) AS rate,
		ISNULL(PRCD.Unit_Of_Measure_ID, 0), <!--- We do nto want UOM to be NULL --->
		CP.Pricing_Level_Id,
		CP.Product_Group_Level_ID,
		1,
		CP.Is_Group,
        1,
        PRCD.User_picked_UOM
				,PRCD.Scan_Percentage
	<cfif arguments.genratereport>
		,BSA.description
		,PRCN.Program_Rebates_Component_Name
		,UOM.Abbreviation_Singular
	</cfif>

		FROM	Program_Rebates_Product_Data prpd
		INNER JOIN Contract_Products cp
		ON cp.Contract_Products_ID = prpd.Contract_Products_ID
		AND cp.Deleted = 0
		AND cp.product_Type_ID = #arguments.ProductTypeID#
		AND CP.Captured_From_Group = 0
		left JOIN dbo.BSA_Foodservice_Items_Master BSA
		ON BSA.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
		LEFT JOIN All_Product_Group_Types PGT
		ON PGT.Group_GUID = CP.BSA_Foodservice_Items_Master_ID
		LEFT JOIN Program_Rebates_Component prc
		ON prc.Program_ID = prpd.Program_ID
		AND prc.Deleted = 0
		LEFT JOIN Program_Rebates_Component_Data prcd
		ON prcd.Program_Rebates_Product_Data_ID = prpd.Program_Rebates_Product_Data_ID
		AND prcd.Program_Rebates_Component_ID = prc.Program_Rebates_Component_ID
		AND prcd.Deleted = 0
	<cfif arguments.genratereport>
		INNER JOIN Units_of_Measure UOM
		ON UOM.Unit_Of_Measure_ID = prpd.Unit_Of_Measure_ID
		INNER JOIN Program_Rebates_Component_Name PRCN
		ON PRCN.Program_Rebates_Component_Name_ID = PRC.Program_Rebates_Component_Name_ID
	</cfif>
		WHERE	prpd.Program_ID = #arguments.contract_main_id#
	<cfif arguments.genratereport>
		ORDER BY Program_Rebates_Component_Name ASC, item ASC
	</cfif>
	</cfquery>
	<cfif arguments.genratereport>
		<cfreturn qExisitingRebatedata>
	<cfelse>
		<cfreturn data.recordCount>
	</cfif>
  </cffunction>
    <!---48162 :: Create Product/Rate List ENHANCEMENT END--->

	<cffunction name="liteAddProducts" output="true">
		<cfargument name="Contract_Main_ID" type="numeric" required="true"  />
		<cfargument name="BSAItemmasterItemID" type="string" required="true"/>
		<cfargument name="Dynamic_Static_Groups" type="numeric" required="true"  />

		<cfset maxPricingLevelID = 1>

		<cfquery name="getPricingLevel" datasource="#application.datasource#">
			SELECT ISNULL(MAX(Pricing_Level_ID), 1) AS Pricing_Level_ID
			FROM Contract_products
			WHERE Contract_Main_ID =  #arguments.Contract_Main_ID#
			AND Is_Group = 0
			AND Captured_From_Group =0
			AND Deleted = 0
			AND Product_Type_ID = 2
		</cfquery>

		<cfif getPricingLevel.RecordCount>
			<cfset maxPricingLevelID = getPricingLevel.Pricing_Level_ID>
		</cfif>

		<cfloop list="#arguments.BSAItemmasterItemID#" index="Item" delimiters=",">
				<cfquery name="iContractProducts" datasource="#application.datasource#">
					IF NOT EXISTS ( SELECT 1 FROM Contract_Products WHERE Contract_Main_ID = #arguments.Contract_Main_ID# AND Product_Type_ID = 2 AND BSA_Foodservice_Items_Master_ID = '#Item#' AND Deleted = 0 AND Captured_From_Group  = 0)
					INSERT INTO	Contract_Products	(
										  Contract_Main_ID
										, Product_Type_ID
										, BSA_Foodservice_Items_Master_ID
										, Product_Group_Level_ID
										, Product_Group_ID
										, Pricing_Level_ID
										, Is_Group
										, Dynamic_Static_Groups
										, EZButton_On_Default
										, EZ_Contract_ID
										, Base_Sales_CS)
					VALUES(
									#arguments.Contract_Main_ID#
									, 2
									, '#Item#'
									, 9
									, ''
									, #getPricingLevel.Pricing_Level_ID#
									, 0
									, #arguments.Dynamic_Static_Groups#
									, 0
									, 0
									, 0
					)
				</cfquery>

			<cfquery name="iPRPD" datasource="#application.datasource#">
					DECLARE @Contract_Products_ID INT
												,@Is_Group BIT

												SELECT 	@Contract_Products_ID = CP.Contract_Products_ID, @Is_Group = Is_Group
												FROM Contract_Products CP
												WHERE CP.Contract_Main_ID = '#arguments.Contract_Main_ID#'
												AND	CP.Product_Type_ID =2
												AND	CP.DELETED = 0
												AND CP.BSA_Foodservice_Items_Master_ID = '#item#'

					IF NOT EXISTS ( SELECT 1
																		FROM Program_Rebates_Product_Data PRPD
																		WHERE PRPD.Contract_Products_ID = @Contract_Products_ID
																		AND PRPD.Deleted = 0
																)
					INSERT INTO	Program_Rebates_Product_Data(
															  Program_ID
															, Contract_Products_ID
															, Volume
															, Unit_Of_Measure_ID
															, Is_Group)
					VALUES(
											#arguments.Contract_Main_ID#
											,@Contract_Products_ID
											,0
											,2
											,@Is_Group
											)
			</cfquery>
		</cfloop>

		<cfquery name="getCompInfo" datasource="#application.datasource#">
			SELECT Program_Rebates_Component_ID, Component_Default_Rate, Component_Default_UOM
			FROM Program_Rebates_Component
			WHERE program_ID =  #arguments.Contract_Main_ID#
			AND Deleted = 0
		</cfquery>

		<cfif getCompInfo.RecordCount>

				<cfquery name="drop_tmp_getBSAInfo" datasource="#application.datasource#">   <!--- 61108 --->
					IF OBJECT_ID('tempdb..##tmp_getBSACompInfo') IS NOT NULL
		 			DROP TABLE ##tmp_getBSACompInfo

			 		CREATE TABLE ##tmp_getBSACompInfo	(
						BSA_Foodservice_Items_Master_ID uniqueidentifier,
						compID Int,
						Rate decimal(20, 4),
						Unit_Of_Measure_Id int,
						Scan_UOM int,
						Scan_Rate decimal(20, 4),
						User_picked_UOM Int
					)
		 	</cfquery>

		<cfloop query = "getCompInfo">
			<cfif getCompInfo.Component_Default_Rate EQ ''>
				<cfset getCompInfo.Component_Default_Rate = 0>
			</cfif>
			<cfquery name="getBSACompInfo" datasource="#application.datasource#">
					INSERT INTO ##tmp_getBSACompInfo (BSA_Foodservice_Items_Master_ID, compID, Rate, Unit_Of_Measure_Id, Scan_UOM, Scan_Rate, User_picked_UOM)
				 SELECT BSA_Foodservice_Items_Master_ID,
				 							#getCompInfo.Program_Rebates_Component_ID#,
				 							<cfif getCompInfo.Component_Default_UOM EQ 5>
			 										#getCompInfo.Component_Default_Rate# * ISNULL(BSA.Case_Count, 1) AS Rate,
			 										1 AS Unit_Of_Measure_Id,
			 										5 AS Scan_UOM,
			 										#getCompInfo.Component_Default_Rate# AS Scan_Rate,
			 										5 AS	User_picked_UOM
				 							<cfelseif getCompInfo.Component_Default_UOM EQ 6>
													#getCompInfo.Component_Default_Rate# / 100 AS Rate,
													2 AS Unit_Of_Measure_Id,
													6 AS Scan_UOM,
													#getCompInfo.Component_Default_Rate# AS Scan_Rate,
													6 AS	User_picked_UOM
				 							<cfelseif getCompInfo.Component_Default_UOM EQ 7>
													#getCompInfo.Component_Default_Rate# *  BSA.Sleeves_Per_Case AS Rate,
													1 AS Unit_Of_Measure_Id,
													7 AS Scan_UOM,
													#getCompInfo.Component_Default_Rate# AS Scan_Rate,
													7 AS	User_picked_UOM
				 							<cfelse>
													#getCompInfo.Component_Default_Rate# AS Rate,
													#getCompInfo.Component_Default_UOM# AS Unit_Of_Measure_Id,
													NULL AS Scan_UOM,
													NULL AS Scan_Rate,
													NULL AS	User_picked_UOM
				 							</cfif>
				 FROM BSA_Foodservice_items_master BSA
				 WHERE BSA.BSA_Foodservice_Items_Master_ID IN (<cfqueryparam list="true" value="#arguments.BSAItemmasterItemID#">)
			</cfquery>
		</cfloop>

		<cfquery name="iPRCD" datasource="#application.datasource#">
			INSERT INTO 	Program_Rebates_Component_Data	(
				  Program_Rebates_Component_ID
				, Program_Rebates_Product_Data_ID
				, rate
				, Unit_Of_Measure_Id
				, Scan_UOM
				, Scan_Rate
				, User_Picked_UOM
			)
			SELECT
				  TMP.compID
				, PRPD.Program_Rebates_Product_Data_ID
				, TMP.rate
				, TMP.Unit_Of_Measure_Id
				, TMP.Scan_UOM
				, TMP.Scan_Rate
				, TMP.User_Picked_UOM
			FROM Contract_Products CP
			INNER JOIN ##tmp_getBSACompInfo TMP
			ON TMP.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
			INNER JOIN Program_Rebates_Product_Data PRPD
			ON PRPD.Contract_Products_ID = CP.Contract_Products_ID
			WHERE CP.Contract_Main_ID = '#arguments.Contract_Main_ID#'
			AND CP.Deleted = 0
			AND PRPD.Deleted = 0
			AND NOT EXISTS (
				SELECT 	1
				FROM 	Program_Rebates_Component_Data cd
				WHERE	cd.Program_Rebates_Component_ID = TMP.compID
				AND		cd.Program_Rebates_Product_Data_ID = PRPD.Program_Rebates_Product_Data_ID
				AND		cd.Deleted = 0
			)
		</cfquery>
	</cfif>
	</cffunction>

	<cffunction name="liteAddComponent" output="true" returntype="void">

		<cfargument name="programId" type="numeric" required="true" default="" />
		<cfargument name="formScope" type="struct" required="true" default="" />
		<cfargument name="componentNameId" required="true" default="" />

		<cfset UpdStatus = UpdateGroupStatus(arguments.programId)>

		<cfquery name="dropCreateTmpTable" datasource="#application.datasource#">   <!--- 61108 --->
			IF OBJECT_ID('tempdb..##tmp_AddCompProdList') IS NOT NULL
			DROP TABLE ##tmp_AddCompProdList

			IF OBJECT_ID('tempdb..##tmp_AddCompProd') IS NOT NULL
			DROP TABLE ##tmp_AddCompProd

			CREATE TABLE ##tmp_AddCompProd(
				Program_Rebates_Component_ID int,
				Program_Rebates_Product_Data_ID int,
				Contract_Products_ID int,
				Rate decimal(20, 4),
				Unit_Of_Measure_Id int,
				Scan_UOM int,
				Scan_Rate decimal(20, 4),
				User_picked_UOM Int
			)
		</cfquery>

		<cfquery name="qGetProgramProducts" datasource="#application.datasource#">   <!--- 61108 --->
			SELECT	DISTINCT cp.Contract_Products_ID,
					pd.Program_Rebates_Product_Data_ID,
					ISNULL(i.Case_Count, 1) as Case_Count,
					ISNULL(i.Sleeves_Per_Case, 0) as Sleeves_Per_Case
			INTO	##tmp_AddCompProdList
			FROM	Contract_Products cp
			INNER JOIN BSA_Foodservice_Items_Master i
			ON		i.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
			INNER JOIN Program_Rebates_Product_Data pd
			ON		pd.Contract_Products_ID = cp.Contract_Products_ID
			AND		pd.Deleted = 0
			WHERE	cp.Contract_Main_ID = #arguments.programId# -- Do not use cfqueryparam
			AND		cp.Deleted = 0
			AND		cp.Product_Type_ID = 2
			AND		cp.Captured_From_Group = 0
		</cfquery>


		<cfparam name="arguments.formScope.Vendor_Master_ID" default="0" />
		<cfparam name="arguments.formScope.VendorSelection" default="" />
		<cfparam name="arguments.formScope.Payee_Selection" default="" />
		<cfparam name="arguments.formScope.GL_Account_ID" default="0" />
		<cfparam name="arguments.formScope.Claim_Mechanics" default="" />
		<cfparam name="arguments.formScope.from_date" default="" />
		<cfparam name="arguments.formScope.to_date" default="" />
		<cfparam name="arguments.formScope.rate" default="" />
		<cfparam name="arguments.formScope.uom" default="1" />
		<cfparam name="arguments.formScope.PaymentCycle" default="1" />
		<cfif arguments.formScope.rate eq "">
			<cfset arguments.formScope.rate = 0 />
		</cfif>

		<cfquery name="GetCompInfo" datasource="#application.datasource#" cachedwithin="#createtimespan(0,0,20,0)#">
			SELECT External_ID, ISNULL(Required_Effective_Rate_Percent, 0) AS Required_Effective_Rate_Percent
			FROM Program_Rebates_Component_Name
			WHERE Program_Rebates_Component_Name_ID = '#arguments.componentNameId#'
		</cfquery>

		<cfquery name="qInsertComps" datasource="#application.datasource#">
			INSERT INTO	Program_Rebates_Component
				(
				Program_Rebates_Component_Name_ID,
				Program_ID,
				Component_Paid_To,
				GL_Account_ID,
				<cfif len(arguments.formScope.Vendor_Master_ID) AND arguments.formScope.Vendor_Master_ID NEQ 0>Vendor_Master_ID,</cfif>
				<cfif len(arguments.formScope.VendorSelection) AND arguments.formScope.VendorSelection NEQ 0>Vendor_Selection,</cfif>
				<cfif len(arguments.formScope.Payee_Selection) AND arguments.formScope.Payee_Selection NEQ 0>Payee_Type,</cfif>
				Claim_Mechanics,
				Effective_Margin_Flag,
				Component_External_ID
				,Calculation_Period_Start ---62343 8.0 - Blended Rate, CF
				,Calculation_Period_End ---62343 8.0 - Blended Rate, CF
				,Component_Default_Rate ---65711
				,Component_Default_UOM ---65711
				)
			VALUES
				(
				<cfqueryparam value="#arguments.componentNameId#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#arguments.formScope.Component_Paid_To#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#arguments.formScope.GL_Account_ID#" cfsqltype="CF_SQL_VARCHAR">,
				<cfif len(arguments.formScope.Vendor_Master_ID) AND arguments.formScope.Vendor_Master_ID NEQ 0><cfqueryparam value="#arguments.formScope.Vendor_Master_ID#" cfsqltype="CF_SQL_VARCHAR">,</cfif>
				<cfif len(arguments.formScope.VendorSelection) AND arguments.formScope.VendorSelection NEQ 0><cfqueryparam value="#arguments.formScope.VendorSelection#" cfsqltype="CF_SQL_INTEGER">,</cfif>
				<cfif len(arguments.formScope.Payee_Selection) AND arguments.formScope.Payee_Selection NEQ 0><cfqueryparam value="#arguments.formScope.Payee_Selection#" cfsqltype="CF_SQL_INTEGER">,</cfif>
				<cfqueryparam value="#arguments.formScope.Claim_Mechanics#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#GetCompInfo.Required_Effective_Rate_Percent#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#GetCompInfo.External_ID#" cfsqltype="CF_SQL_VARCHAR">
				,<cfqueryparam value="#arguments.formScope.from_date#" cfsqltype="CF_SQL_DATE">
				,<cfqueryparam value="#arguments.formScope.to_date#" cfsqltype="CF_SQL_DATE">
				,<cfqueryparam value="#arguments.formScope.rate#" cfsqltype="CF_SQL_VARCHAR">
				,<cfqueryparam value="#arguments.formScope.uom#" cfsqltype="CF_SQL_INTEGER">
				)
		</cfquery>

		<cfset Program_Rebates_Component_ID = qInsertComps.Program_Rebates_Component_ID />

		<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
		<cfif appSettings.getPaymentCycleAtDiscountType() AND len(trim(arguments.formScope.PaymentCycle))>
			<cfset paymentCycleManager = CreateObject("component", "components.programs.PaymentCycleManager").init() />
			<cfset paymentCycleManager.savePaymentCycle(arguments.programId, 2, arguments.formScope.PaymentCycle,Program_Rebates_Component_ID) />
		</cfif>

		<cfset defaultRate = arguments.formScope.rate />
		<cfset defaultUOM = arguments.formScope.uom />
		<cfset convertedUOM = arguments.formScope.uom />

		<!---- Insert Program_Rebates_Component_Data ---->
		<cfquery name="insertComponent" datasource="#application.datasource#">
			INSERT INTO Program_Rebates_Component_Data (Program_Rebates_Component_ID,
			Program_Rebates_Product_Data_ID, Rate, Unit_Of_Measure_Id, Scan_UOM, Scan_Rate, User_picked_UOM)

			SELECT 	#Program_Rebates_Component_ID#,
					Program_Rebates_Product_Data_ID,
				<cfif defaultUOM EQ 5>
					<cfset convertedUOM = 1 />
					cast( #defaultRate# * cast(BSA.Case_Count as decimal(18,4)) as decimal(18,4)) AS Rate,
					1 AS Unit_Of_Measure_Id,
					5 AS Scan_UOM,
					#defaultRate# AS Scan_Rate,
					5 AS	User_picked_UOM
				<cfelseif defaultUOM EQ 6>
					<cfset convertedUOM = 2 />
					#defaultRate# / 100 AS Rate,
					2 AS Unit_Of_Measure_Id,
					6 AS Scan_UOM,
					#defaultRate# AS Scan_Rate,
					6 AS	User_picked_UOM
				<cfelseif defaultUOM EQ 7>
					<cfset convertedUOM = 1 />
					cast( #defaultRate# * cast(BSA.Sleeves_Per_Case as decimal(18,4)) as decimal(18,4)) AS Rate,
					1 AS Unit_Of_Measure_Id,
					7 AS Scan_UOM,
					#defaultRate# AS Scan_Rate,
					7 AS	User_picked_UOM
				<cfelse>
					#defaultRate# AS Rate,
					#defaultUOM# AS Unit_Of_Measure_Id,
					NULL AS Scan_UOM,
					NULL AS Scan_Rate,
					NULL AS	User_picked_UOM
				</cfif>
			FROM	##tmp_AddCompProdList BSA
			WHERE NOT EXISTS (
				SELECT 	1
				FROM 	Program_Rebates_Component_Data cd
				WHERE	cd.Program_Rebates_Component_ID = #Program_Rebates_Component_ID#
				AND		cd.Program_Rebates_Product_Data_ID = BSA.Program_Rebates_Product_Data_ID
				AND		cd.Deleted = 0
			)

		</cfquery>

		<!---- Insert Program_Rebate_Alternate_Recapture_Rate ---->
		<cfquery name="qInsertAltRecapRate" datasource="#application.datasource#">
			INSERT INTO Program_Rebate_Alternate_Recapture_Rate	(
				  Program_Rebates_Component_ID, Contract_Main_ID, Contract_Products_ID, Alternate_Recapture_Rate_Index, Rate, UOM
			)
			SELECT
				  #Program_Rebates_Component_ID#
				, #arguments.programId#
				, TMP.Contract_Products_ID
				, 1
				, 0
				, #convertedUOM#
			FROM ##tmp_AddCompProdList TMP
			WHERE NOT EXISTS (
				SELECT 	1
				FROM 	Program_Rebate_Alternate_Recapture_Rate cd
				WHERE	cd.Program_Rebates_Component_ID = #Program_Rebates_Component_ID#
				AND		cd.Contract_Products_ID = TMP.Contract_Products_ID
			)
		</cfquery>

	</cffunction>

</cfcomponent>